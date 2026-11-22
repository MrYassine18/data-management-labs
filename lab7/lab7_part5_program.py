import mysql.connector
from mysql.connector import Error

DB_CONFIG = {
    "host": "localhost",
    "user": "root",
    "password": "YOUR_PASSWORD",
    "database": "rlms",
}

LAB_NAME = "Physics Laboratory"


def task3_units_in_service(conn, lab_name):
    query = """
        SELECT u.serialNo, m.commercialName
        FROM EquipmentUnit u
        JOIN EquipmentModel m ON m.modelId = u.modelId
        JOIN Laboratory l ON l.labId = u.labId
        WHERE l.name = %s
          AND u.status = 'InService'
        ORDER BY u.serialNo
    """
    cursor = conn.cursor()
    cursor.execute(query, (lab_name,))

    print(f"Task 3 - InService units in '{lab_name}':")
    count = 0
    for serial_no, model_name in cursor:
        print(f"  {serial_no:<6} {model_name}")
        count += 1
    if count == 0:
        print("  (no unit found)")
    cursor.close()


def task4_low_stock(conn):
    cursor = conn.cursor()
    cursor.execute("SELECT * FROM LaboratoryStockSummary WHERE stockLevel = %s", ("LOW",))

    columns = cursor.column_names
    rows = cursor.fetchall()

    print("\nTask 4 - consumables with a LOW stock level:")
    if not rows:
        print("  (no low stock)")
    for row in rows:
        print("  " + ", ".join(f"{col}={val}" for col, val in zip(columns, row)))
    cursor.close()


def task5_restock(conn, lab_id, cons_id, qty):
    cursor = conn.cursor()
    try:
        result = cursor.callproc("RestockLab", (lab_id, cons_id, qty, 0))
        conn.commit()
        print(f"\nTask 5 - RestockLab({lab_id}, {cons_id}, {qty}): new quantity = {result[3]}")
    except Error as err:
        conn.rollback()
        print(f"\nTask 5 - RestockLab rejected: {err.msg}")
    finally:
        cursor.close()


def task6_rejected_reservation(conn):
    cursor = conn.cursor()
    try:
        cursor.execute("INSERT INTO Reserves (resId, serialNo) VALUES (%s, %s)", (1, "U3"))
        conn.commit()
        print("\nTask 6 - insertion accepted (unexpected)")
    except Error as err:
        conn.rollback()
        print("\nTask 6 - the trigger rejected the insertion:")
        print(f"  {err.msg}")
    finally:
        cursor.close()


def run_step(name, step):
    try:
        step()
    except Error as err:
        print(f"\n{name} failed: {err.msg}")


def main():
    try:
        conn = mysql.connector.connect(**DB_CONFIG)
    except Error as err:
        print(f"Cannot connect to the database: {err}")
        return

    try:
        run_step("Task 3", lambda: task3_units_in_service(conn, LAB_NAME))
        run_step("Task 4", lambda: task4_low_stock(conn))
        run_step("Task 5", lambda: task5_restock(conn, 1, 1, 25))
        run_step("Task 6", lambda: task6_rejected_reservation(conn))
    finally:
        conn.close()
    print("\nProgram finished normally.")


if __name__ == "__main__":
    main()
