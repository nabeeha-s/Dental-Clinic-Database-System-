# Dental-Clinic-Database-System
Python/Oracle application with Tkinter GUI implementing normalized database schema (3NF/BCNF), sequences, views, and comprehensive patient management. This project includes a shell-driven Database Management System built for a dental clinic, which is operated through a clean terminal menu (menu.sh).

# For the Bash Script (A9)
1) Prerequisites
SSH access to <pre> ```moon.scs.ryerson.ca``` </pre>
In the server SSH  <pre> ```your_username@moon.scs.ryerson.ca ``` </pre>
Navigate to the project directory cd CPS510
Run the main menu script <pre> ```./menu.sh ``` </pre>

2) Configuration
where necessary, replace 'username' and 'password' with your actual credentials <pre> ```sqlplus64 "username/password@(DESCRIPTION=(ADDRESS=(PROTOCOL=TCP)(Host=oracle12c.scs.ryerson.ca)(Port=1521))(CONNECT_DATA=(SID=orcl12c)))"``` </pre>

3) Troubleshooting
<pre> chmod +x menu.sh </pre>

<pre> # Project Structure 
  CPS510/
  ├── menu.sh             # Main menu interface
  ├── create_tables.sh    # Schema initialization
  ├── drop_tables.sh      # Database cleanup
  ├── populate_tables.sh  # Sample data loading
  ├── queries.sh          # Comprehensive query reports
  └── Oracle12c.sql       # Complete SQL schema & data </pre>

  # For the Web UI
  1) Prerequisites
- Python 3.8+
- Oracle Instant Client + ORACLE_HOME or Oracle DB access
- `sqlplus` or Oracle SQL*Plus/SQLcl available (for loading SQL)

  2) Credentials Configuration

Update the database connection section with your own Oracle credentials.

Replace:
    username = "[username]"
    password = "[password]"

with your actual Oracle login details provided by the server.

  3) Install Python deps
  ```bash
  python3 -m venv venv
  source venv/bin/activate
  pip install -r requirements.txt
  pip install oracledb
