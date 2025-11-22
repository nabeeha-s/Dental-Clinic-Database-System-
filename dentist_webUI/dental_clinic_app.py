import tkinter as tk
from tkinter import *
import oracledb as cx_Oracle

root = Tk()
root.title('Dental Clinic DBMS GUI')
root.geometry("800x600")

# Global variables
connection = None
cursor = None
username = ""
password = ""

# Table options
OPTIONS = [""]

# Creating window frames
login = Frame(root)
mainwindow = Frame(root)
view_tables_page = Frame(root)
query_page = Frame(root)
update_page = Frame(root)
create_tables_page = Frame(root)
drop_tables_page = Frame(root)

# Creating function to switch window
def frameraise(frame):
    frame.tkraise()

# Creating function to manage frames
for frame in (login, mainwindow, view_tables_page, query_page, update_page, create_tables_page, drop_tables_page):
    frame.grid(row=0, column=0, sticky='news')

# Create function to manage login
def create_connection():
    global username, password, cursor, connection
    
    # Hardcoded credentials // insert your own Oracle DB credentials here
    username = "[username]]"
    password = "[password]"
    
    try:
        connection = cx_Oracle.connect(
            user=username,
            password=password,
            dsn="(DESCRIPTION=(ADDRESS=(PROTOCOL=TCP)(Host=oracle12c.scs.ryerson.ca)(Port=1521))(CONNECT_DATA=(SID=orcl12c)))"
        )

        if connection.version != 0:
            print(f"Connected to Oracle version: {connection.version}")
            cursor = connection.cursor()
            frameraise(mainwindow)
            update_table_list()
            status_label.config(text="Connected successfully!", fg="green")

    except Exception as e:
        ins.config(text=f"Login failed. Error: {str(e)}", fg="red")

def update_table_list():
    """Update the table dropdown with current database tables"""
    global OPTIONS
    try:
        cursor.execute("SELECT table_name FROM user_tables ORDER BY table_name")
        tables = cursor.fetchall()
        OPTIONS = [""] + [table[0] for table in tables]
        
        # Update all dropdown menus
        update_menu(view_table_dropdown, view_table_var)
        update_menu(query_table_dropdown, query_table_var)
        
    except Exception as e:
        print(f"Error updating table list: {e}")

def update_menu(dropdown, variable):
    """Update a dropdown menu with current OPTIONS"""
    dropdown["menu"].delete(0, "end")
    for option in OPTIONS:
        dropdown["menu"].add_command(
            label=option, 
            command=tk._setit(variable, option)
        )
    if OPTIONS:
        variable.set(OPTIONS[0])

# View Tables Functions
def view_table_click():
    table_name = view_table_var.get()
    if not table_name:
        view_result.config(state=NORMAL)
        view_result.delete('1.0', END)
        view_result.insert(END, "Please select a table")
        view_result.config(state=DISABLED)
        return
        
    try:
        query = f"SELECT * FROM {table_name}"
        cursor.execute(query)
        rows = cursor.fetchall()
        columns = [desc[0] for desc in cursor.description]
        
        view_result.config(state=NORMAL)
        view_result.delete('1.0', END)
        
        # Display column headers
        header = " | ".join(columns) + "\n" + "-" * (len(columns) * 15) + "\n"
        view_result.insert(END, header)
        
        # Display data
        for row in rows:
            row_str = " | ".join(str(cell) for cell in row) + "\n"
            view_result.insert(END, row_str)
            
        view_result.insert(END, f"\nTotal records: {len(rows)}")
        view_result.config(state=DISABLED)
        
    except Exception as e:
        view_result.config(state=NORMAL)
        view_result.delete('1.0', END)
        view_result.insert(END, f"Error: {str(e)}")
        view_result.config(state=DISABLED)

# Query Functions
def execute_query():
    query = query_input.get("1.0", END).strip()
    if not query:
        query_result.config(state=NORMAL)
        query_result.delete('1.0', END)
        query_result.insert(END, "Please enter a query")
        query_result.config(state=DISABLED)
        return
        
    try:
        cursor.execute(query)
        
        if query.upper().startswith('SELECT'):
            rows = cursor.fetchall()
            columns = [desc[0] for desc in cursor.description] if cursor.description else []
            
            query_result.config(state=NORMAL)
            query_result.delete('1.0', END)
            
            if columns:
                # Display column headers
                header = " | ".join(columns) + "\n" + "-" * (len(columns) * 15) + "\n"
                query_result.insert(END, header)
            
            # Display data
            for row in rows:
                row_str = " | ".join(str(cell) for cell in row) + "\n"
                query_result.insert(END, row_str)
                
            query_result.insert(END, f"\nTotal records: {len(rows)}")
        else:
            connection.commit()
            query_result.config(state=NORMAL)
            query_result.delete('1.0', END)
            query_result.insert(END, "Query executed successfully!")
            
        query_result.config(state=DISABLED)
        
    except Exception as e:
        query_result.config(state=NORMAL)
        query_result.delete('1.0', END)
        query_result.insert(END, f"Error: {str(e)}")
        query_result.config(state=DISABLED)

def load_predefined_query():
    predefined_queries = {
        "Appointment Overview": """
            SELECT a.AppointmentID, p.FirstName || ' ' || p.LastName as PatientName,
                   d.FirstName || ' ' || d.LastName as DentistName,
                   TO_CHAR(a.AppointmentDateTime, 'YYYY-MM-DD HH24:MI') as AppointmentTime,
                   a.Status, a.Reason
            FROM Appointment a
            JOIN Patient p ON a.PatientID = p.PatientID
            JOIN Dentist d ON a.DentistID = d.DentistID
            ORDER BY a.AppointmentDateTime
        """,
        "Patient Outstanding Balances": """
            SELECT p.PatientID, p.FirstName || ' ' || p.LastName as PatientName,
                   SUM(b.TotalAmount - b.AmountPaid) as OutstandingBalance
            FROM Patient p
            JOIN Bills b ON p.PatientID = b.PatientID
            WHERE b.PaymentStatus != 'Paid'
            GROUP BY p.PatientID, p.FirstName, p.LastName
            HAVING SUM(b.TotalAmount - b.AmountPaid) > 0
            ORDER BY OutstandingBalance DESC
        """,
        "Treatment Cost Analysis": """
            SELECT TreatmentType, 
                   COUNT(*) as NumberOfTreatments,
                   ROUND(AVG(TreatmentCost), 2) as AverageCost,
                   SUM(TreatmentCost) as TotalRevenue
            FROM Treatment
            GROUP BY TreatmentType
            ORDER BY NumberOfTreatments DESC
        """
    }
    
    selected_query = query_var.get()
    if selected_query in predefined_queries:
        query_input.delete('1.0', END)
        query_input.insert(END, predefined_queries[selected_query])

# Update Functions
def execute_update():
    query_type = update_type_var.get()
    query = update_input.get("1.0", END).strip()
    
    if not query:
        update_result.config(state=NORMAL)
        update_result.delete('1.0', END)
        update_result.insert(END, "Please enter a query")
        update_result.config(state=DISABLED)
        return
        
    try:
        cursor.execute(query)
        connection.commit()
        
        update_result.config(state=NORMAL)
        update_result.delete('1.0', END)
        update_result.insert(END, f"{query_type} executed successfully!")
        update_result.config(state=DISABLED)
        
        # Refresh table list if structure might have changed
        update_table_list()
        
    except Exception as e:
        update_result.config(state=NORMAL)
        update_result.delete('1.0', END)
        update_result.insert(END, f"Error: {str(e)}")
        update_result.config(state=DISABLED)

def load_update_example():
    examples = {
        "INSERT": "INSERT INTO Patient (PatientID, FirstName, LastName, Phone, Email) VALUES (seq_patient.NEXTVAL, 'John', 'Smith', '555-1234', 'john@example.com')",
        "UPDATE": "UPDATE Patient SET Phone = '555-5678' WHERE PatientID = 1",
        "DELETE": "DELETE FROM Patient WHERE PatientID = 5"
    }
    
    query_type = update_type_var.get()
    if query_type in examples:
        update_input.delete('1.0', END)
        update_input.insert(END, examples[query_type])

# Create Tables Function
def create_tables():
    try:
        # Read and execute the SQL script
        with open('Oracle12c.sql', 'r') as file:
            sql_script = file.read()
        
        # Split by semicolons and execute each statement
        statements = sql_script.split(';')
        for statement in statements:
            statement = statement.strip()
            if statement and not statement.startswith('--'):
                try:
                    cursor.execute(statement)
                except Exception as e:
                    print(f"Warning: {e}")
        
        connection.commit()
        create_result.config(state=NORMAL)
        create_result.delete('1.0', END)
        create_result.insert(END, "All dental clinic tables created and populated successfully!")
        create_result.config(state=DISABLED)
        
        # Refresh table list
        update_table_list()
        
    except Exception as e:
        create_result.config(state=NORMAL)
        create_result.delete('1.0', END)
        create_result.insert(END, f"Error: {str(e)}")
        create_result.config(state=DISABLED)

# Drop Tables Function
def drop_tables():
    try:
        # Safe drop all objects
        drop_queries = [
            "BEGIN EXECUTE IMMEDIATE 'DROP TABLE BillItems CASCADE CONSTRAINTS'; EXCEPTION WHEN OTHERS THEN NULL; END;",
            "BEGIN EXECUTE IMMEDIATE 'DROP TABLE Bills CASCADE CONSTRAINTS'; EXCEPTION WHEN OTHERS THEN NULL; END;",
            "BEGIN EXECUTE IMMEDIATE 'DROP TABLE Prescription CASCADE CONSTRAINTS'; EXCEPTION WHEN OTHERS THEN NULL; END;",
            "BEGIN EXECUTE IMMEDIATE 'DROP TABLE Treatment CASCADE CONSTRAINTS'; EXCEPTION WHEN OTHERS THEN NULL; END;",
            "BEGIN EXECUTE IMMEDIATE 'DROP TABLE Appointment CASCADE CONSTRAINTS'; EXCEPTION WHEN OTHERS THEN NULL; END;",
            "BEGIN EXECUTE IMMEDIATE 'DROP TABLE PatientAllergy CASCADE CONSTRAINTS'; EXCEPTION WHEN OTHERS THEN NULL; END;",
            "BEGIN EXECUTE IMMEDIATE 'DROP TABLE Allergy CASCADE CONSTRAINTS'; EXCEPTION WHEN OTHERS THEN NULL; END;",
            "BEGIN EXECUTE IMMEDIATE 'DROP TABLE MedicalRecord CASCADE CONSTRAINTS'; EXCEPTION WHEN OTHERS THEN NULL; END;",
            "BEGIN EXECUTE IMMEDIATE 'DROP TABLE DentistSpecialization CASCADE CONSTRAINTS'; EXCEPTION WHEN OTHERS THEN NULL; END;",
            "BEGIN EXECUTE IMMEDIATE 'DROP TABLE InsuranceProvider CASCADE CONSTRAINTS'; EXCEPTION WHEN OTHERS THEN NULL; END;",
            "BEGIN EXECUTE IMMEDIATE 'DROP TABLE Patient CASCADE CONSTRAINTS'; EXCEPTION WHEN OTHERS THEN NULL; END;",
            "BEGIN EXECUTE IMMEDIATE 'DROP TABLE Dentist CASCADE CONSTRAINTS'; EXCEPTION WHEN OTHERS THEN NULL; END;",
            "BEGIN EXECUTE IMMEDIATE 'DROP TABLE Specialization CASCADE CONSTRAINTS'; EXCEPTION WHEN OTHERS THEN NULL; END;",
            "BEGIN EXECUTE IMMEDIATE 'DROP TABLE Staff CASCADE CONSTRAINTS'; EXCEPTION WHEN OTHERS THEN NULL; END;"
        ]
        
        for query in drop_queries:
            cursor.execute(query)
        
        connection.commit()
        drop_result.config(state=NORMAL)
        drop_result.delete('1.0', END)
        drop_result.insert(END, "All dental clinic tables dropped successfully!")
        drop_result.config(state=DISABLED)
        
        # Refresh table list
        update_table_list()
        
    except Exception as e:
        drop_result.config(state=NORMAL)
        drop_result.delete('1.0', END)
        drop_result.insert(END, f"Error: {str(e)}")
        drop_result.config(state=DISABLED)

# Exit function
def exit_click():
    if cursor:
        cursor.close()
    if connection:
        connection.close()
    close_window()

def close_window():
    root.quit()
    root.destroy()

# Changes the behaviour of the [x] button
root.protocol("WM_DELETE_WINDOW", close_window)

# ===== LOGIN PAGE =====
welcome = Label(login, text='Welcome to Dental Clinic DBMS', font=('Arial', 16, 'bold'))
ins = Label(login, text="Please enter your Oracle database credentials")

# User field
user_frame = Frame(login)
user_text = Label(user_frame, text='Username:')
user = Entry(user_frame, width=20)
user_text.pack(side=LEFT, padx=5)
user.pack(side=RIGHT, padx=5)

# Password field
pass_frame = Frame(login)
pass_text = Label(pass_frame, text='Password:')
pwd = Entry(pass_frame, show='*', width=20)
pass_text.pack(side=LEFT, padx=5)
pwd.pack(side=RIGHT, padx=5)

login_button = Button(login, text='Login', command=create_connection, bg='green', fg='white')
status_label = Label(login, text="", fg="blue")

# ===== MAIN WINDOW =====
introLabel = Label(mainwindow, text="Dental Clinic Database Management System", font=('Arial', 14, 'bold'))
descLabel = Label(mainwindow, text="Normalized Schema (3NF/BCNF) with Sequences and Views", wraplength=500)

# Menu buttons
to_view_tables = Button(mainwindow, text='View Tables', width=30, command=lambda: frameraise(view_tables_page))
to_query = Button(mainwindow, text='Query Database', width=30, command=lambda: frameraise(query_page))
to_update = Button(mainwindow, text='Edit Data', width=30, command=lambda: frameraise(update_page))
to_create = Button(mainwindow, text='Create Tables', width=30, command=lambda: frameraise(create_tables_page))
to_drop = Button(mainwindow, text='Drop Tables', width=30, command=lambda: frameraise(drop_tables_page))
exit_button = Button(mainwindow, text='Exit', width=30, command=exit_click, bg='red', fg='white')

# ===== VIEW TABLES PAGE =====
view_back_button = Button(view_tables_page, text='Back to Main', command=lambda: frameraise(mainwindow))
view_table_label = Label(view_tables_page, text="Select Table to View:")
view_table_var = StringVar(view_tables_page)
view_table_dropdown = OptionMenu(view_tables_page, view_table_var, *OPTIONS)
view_table_button = Button(view_tables_page, text='View Table', command=view_table_click)
view_result = Text(view_tables_page, wrap=WORD, height=20, width=80, state=DISABLED)
view_scrollbar = Scrollbar(view_tables_page, command=view_result.yview)
view_result.config(yscrollcommand=view_scrollbar.set)

# ===== QUERY PAGE =====
query_back_button = Button(query_page, text='Back to Main', command=lambda: frameraise(mainwindow))
query_label = Label(query_page, text="Database Queries", font=('Arial', 12, 'bold'))

# Predefined queries
predefined_label = Label(query_page, text="Predefined Queries:")
query_var = StringVar(query_page)
query_dropdown = OptionMenu(query_page, query_var, "Appointment Overview", "Patient Outstanding Balances", "Treatment Cost Analysis")
load_query_button = Button(query_page, text="Load Query", command=load_predefined_query)

# Custom query
custom_label = Label(query_page, text="Custom SQL Query:")
query_input = Text(query_page, height=8, width=80)
query_execute_button = Button(query_page, text="Execute Query", command=execute_query, bg='blue', fg='white')
query_result = Text(query_page, wrap=WORD, height=15, width=80, state=DISABLED)
query_scrollbar = Scrollbar(query_page, command=query_result.yview)
query_result.config(yscrollcommand=query_scrollbar.set)

# ===== UPDATE PAGE =====
update_back_button = Button(update_page, text='Back to Main', command=lambda: frameraise(mainwindow))
update_label = Label(update_page, text="Edit Database Tables", font=('Arial', 12, 'bold'))

# Update type selection
update_type_label = Label(update_page, text="Query Type:")
update_type_var = StringVar(update_page)
update_type_dropdown = OptionMenu(update_page, update_type_var, "INSERT", "UPDATE", "DELETE")
load_example_button = Button(update_page, text="Load Example", command=load_update_example)

# Update input
update_input_label = Label(update_page, text="SQL Statement:")
update_input = Text(update_page, height=6, width=80)
update_execute_button = Button(update_page, text="Execute", command=execute_update, bg='orange')
update_result = Text(update_page, wrap=WORD, height=10, width=80, state=DISABLED)

# Safety warning
safety_label = Label(update_page, text="⚠️ Important: Always use WHERE clauses in UPDATE and DELETE statements!", 
                    fg='red', wraplength=500)

# ===== CREATE TABLES PAGE =====
create_back_button = Button(create_tables_page, text='Back to Main', command=lambda: frameraise(mainwindow))
create_label = Label(create_tables_page, text="Create Database Tables", font=('Arial', 12, 'bold'))
create_info = Label(create_tables_page, text="This will create all dental clinic tables with sample data", wraplength=500)
create_button = Button(create_tables_page, text="Create Tables", command=create_tables, bg='green', fg='white')
create_result = Text(create_tables_page, wrap=WORD, height=10, width=80, state=DISABLED)

# ===== DROP TABLES PAGE =====
drop_back_button = Button(drop_tables_page, text='Back to Main', command=lambda: frameraise(mainwindow))
drop_label = Label(drop_tables_page, text="Drop Database Tables", font=('Arial', 12, 'bold'))
drop_warning = Label(drop_tables_page, text="⚠️ WARNING: This will delete ALL data and tables!", fg='red', wraplength=500)
drop_button = Button(drop_tables_page, text="Drop All Tables", command=drop_tables, bg='red', fg='white')
drop_result = Text(drop_tables_page, wrap=WORD, height=10, width=80, state=DISABLED)

# ===== LAYOUTS =====

# Login layout
login.columnconfigure(0, weight=1, minsize=570)
for i in range(6):
    login.rowconfigure(i, weight=1, minsize=10)
welcome.grid(row=0, column=0, pady=20, sticky="n")
ins.grid(row=1, column=0, pady=5, sticky="n")
user_frame.grid(row=2, column=0, pady=5, sticky="n")
pass_frame.grid(row=3, column=0, pady=5, sticky="n")
login_button.grid(row=4, column=0, pady=10, sticky="n")
status_label.grid(row=5, column=0, pady=5, sticky="n")

# Main window layout
mainwindow.columnconfigure(0, weight=1, minsize=570)
introLabel.grid(row=0, column=0, pady=10, sticky="n")
descLabel.grid(row=1, column=0, pady=5, sticky="n")
to_view_tables.grid(row=2, column=0, padx=5, pady=5, sticky="ns")
to_query.grid(row=3, column=0, padx=5, pady=5, sticky="ns")
to_update.grid(row=4, column=0, padx=5, pady=5, sticky="ns")
to_create.grid(row=5, column=0, padx=5, pady=5, sticky="ns")
to_drop.grid(row=6, column=0, padx=5, pady=5, sticky="ns")
exit_button.grid(row=7, column=0, padx=5, pady=10, sticky="ns")

# View tables layout
view_tables_page.columnconfigure(0, weight=1)
view_back_button.grid(row=0, column=0, padx=5, pady=5, sticky="w")
view_table_label.grid(row=1, column=0, padx=5, pady=5, sticky="w")
view_table_dropdown.grid(row=2, column=0, padx=5, pady=5, sticky="w")
view_table_button.grid(row=3, column=0, padx=5, pady=5, sticky="w")
view_result.grid(row=4, column=0, padx=5, pady=5, sticky="nsew")
view_scrollbar.grid(row=4, column=1, sticky="ns")

# Query page layout
query_page.columnconfigure(0, weight=1)
query_back_button.grid(row=0, column=0, padx=5, pady=5, sticky="w")
query_label.grid(row=1, column=0, padx=5, pady=5, sticky="w")
predefined_label.grid(row=2, column=0, padx=5, pady=5, sticky="w")
query_dropdown.grid(row=3, column=0, padx=5, pady=5, sticky="w")
load_query_button.grid(row=4, column=0, padx=5, pady=5, sticky="w")
custom_label.grid(row=5, column=0, padx=5, pady=5, sticky="w")
query_input.grid(row=6, column=0, padx=5, pady=5, sticky="nsew")
query_execute_button.grid(row=7, column=0, padx=5, pady=5, sticky="w")
query_result.grid(row=8, column=0, padx=5, pady=5, sticky="nsew")
query_scrollbar.grid(row=8, column=1, sticky="ns")

# Update page layout
update_page.columnconfigure(0, weight=1)
update_back_button.grid(row=0, column=0, padx=5, pady=5, sticky="w")
update_label.grid(row=1, column=0, padx=5, pady=5, sticky="w")
update_type_label.grid(row=2, column=0, padx=5, pady=5, sticky="w")
update_type_dropdown.grid(row=3, column=0, padx=5, pady=5, sticky="w")
load_example_button.grid(row=4, column=0, padx=5, pady=5, sticky="w")
update_input_label.grid(row=5, column=0, padx=5, pady=5, sticky="w")
update_input.grid(row=6, column=0, padx=5, pady=5, sticky="nsew")
update_execute_button.grid(row=7, column=0, padx=5, pady=5, sticky="w")
safety_label.grid(row=8, column=0, padx=5, pady=10, sticky="w")
update_result.grid(row=9, column=0, padx=5, pady=5, sticky="nsew")

# Create tables layout
create_tables_page.columnconfigure(0, weight=1)
create_back_button.grid(row=0, column=0, padx=5, pady=5, sticky="w")
create_label.grid(row=1, column=0, padx=5, pady=5, sticky="w")
create_info.grid(row=2, column=0, padx=5, pady=5, sticky="w")
create_button.grid(row=3, column=0, padx=5, pady=10, sticky="w")
create_result.grid(row=4, column=0, padx=5, pady=5, sticky="nsew")

# Drop tables layout
drop_tables_page.columnconfigure(0, weight=1)
drop_back_button.grid(row=0, column=0, padx=5, pady=5, sticky="w")
drop_label.grid(row=1, column=0, padx=5, pady=5, sticky="w")
drop_warning.grid(row=2, column=0, padx=5, pady=5, sticky="w")
drop_button.grid(row=3, column=0, padx=5, pady=10, sticky="w")
drop_result.grid(row=4, column=0, padx=5, pady=5, sticky="nsew")

# Configure row weights for scrollable areas
view_tables_page.rowconfigure(4, weight=1)
query_page.rowconfigure(8, weight=1)
update_page.rowconfigure(9, weight=1)
create_tables_page.rowconfigure(4, weight=1)
drop_tables_page.rowconfigure(4, weight=1)

# Start the application
frameraise(login)
root.mainloop()