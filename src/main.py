from gui import *
from bindings import *
from utils import *
from ui_interface import UltraKeyUI
from datetime import datetime, timezone, timedelta
import time
import sys

# This is the cutoff: 5:00 PM PST, March 23, 2025
CUTOFF_UNIX_TIME = 1742778000

def time_limit():
    # Set cutoff time: 5:00 PM PST (UTC-8) on 3/23/2025
    pst_offset = timedelta(hours=-8)
    cutoff_dt = datetime(2025, 3, 23, 17, 0, 0, tzinfo=timezone(pst_offset))
    CUTOFF_UNIX_TIME = int(cutoff_dt.timestamp())

    # Get current Unix time
    current_time = time.time()
    remaining_seconds = int(CUTOFF_UNIX_TIME - current_time)

    if remaining_seconds <= 0:
        print("App expired at 5:00 PM PST, 3/23/2025.")
        sys.exit(1)

    # Convert remaining time to H:M:S
    hours = remaining_seconds // 3600
    minutes = (remaining_seconds % 3600) // 60
    seconds = remaining_seconds % 60

    print(f"Time remaining: {hours:02}:{minutes:02}:{seconds:02}")

if __name__ == "__main__":
    # time_limit()
    gui: GUI = GUI()
    UltraKeyUI(gui) 
    gui.show()