# Dental-Clinic-Database-System-
Developing an SQL database for an online dental clinic system. This project is mainly a shell-driven Database Management System built for a dental clinic. Everything is operated through a clean terminal menu (menu.sh).

# For the Bash Script (A9)
SSH access to moon.scs.ryerson.ca
In the server SSH your_username@moon.scs.ryerson.ca
Navigate to the project directory cd CPS510
Run the main menu script ./menu.sh

# Configuration
where necessary, replace 'username' and 'password' with your actual credentials
sqlplus64 "username/password@(DESCRIPTION=(ADDRESS=(PROTOCOL=TCP)(Host=oracle12c.scs.ryerson.ca)(Port=1521))(CONNECT_DATA=(SID=orcl12c)))"

# Troubleshooting
chmod +x menu.sh

# Project Structure
CPS510/
├── menu.sh                 # Main menu interface
├── create_tables.sh        # Schema initialization
├── drop_tables.sh          # Database cleanup
├── populate_tables.sh      # Sample data loading
├── queries.sh              # Comprehensive query reports
└── Oracle12c.sql           # Complete SQL schema & data
