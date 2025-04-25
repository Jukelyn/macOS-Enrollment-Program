# NC State COS JAMF Enrollment Helper

<!-- The full documentation can be found [here on GitHub Pages](https://pages.github.ncsu.edu/Mathematics/macOS-Enrollment-UI/). -->

## Overview

This is the **NC State College of Sciences (COS) JAMF Enrollment Helper**, a graphical user interface (GUI) application designed for macOS users within COS. Its purpose is to easily collect necessary user information (first name, last name, department, building) and use it to update the computer's record in JAMF Pro via the `jamf recon` command.

This tool streamlines the information update process, helping to ensure computers are correctly categorized within the JAMF Pro server.

This project was developed by Mehraz Ahmed with assistance from Imraan Khan.

## Key Features

- **User-Friendly Interface:** A simple, multi-page workflow built with [CustomTkinter](https://github.com/TomSchimansky/CustomTkinter) guides the user through the necessary steps (Acknowledgement, Name Input, Department/Building Selection, Submission).
- **JAMF Integration:** Automatically constructs and executes the `jamf recon` command with the collected information (`--realname`, `--building`, `--department`).
- **Loading Indicator:** Provides visual feedback via a loading screen while the `jamf recon` command runs asynchronously (using threading), preventing the UI from freezing.
- **Dynamic Selection:** Populates Department & Building dropdown menus from the external `buildings_departments.txt` file for easy and consistent selection.
- **Logging:** Saves submitted information (timestamp, name, building, department group) to `info_log.txt` for record-keeping.
- **Custom Styling:** Features NC State branding elements (banner, background) and uses a dark theme by default.
- **Accessibility:** GUI elements (labels, entry fields, dropdowns, buttons) dynamically scale based on a scaling factor defined in the script.

## Technical Details

- Built primarily using Python and the CustomTkinter library.
- Uses the `Pillow` library for image processing (background, banner).
- Leverages Python's built-in `subprocess` module to execute the `jamf recon` command.
- Uses the `threading` module to run the submission process asynchronously, allowing for a responsive loading screen.

## Requirements

- **Operating System:** macOS (Designed and tested for macOS due to JAMF dependency and specific command paths).
- **Python:** Version 3.9 through 3.12.
- **JAMF Pro Binary:** The `jamf` command-line tool **must** be installed and accessible at the standard location: `/usr/local/bin/jamf`.
- **Python Libraries:**
  - `customtkinter`
  - `Pillow`

## Installation (for Development / Local Testing)

These instructions are for setting up a local development or testing environment. See the **Usage** section for the intended deployment method.

1.  **Clone the Repository:**
    ```bash
    git clone https://github.com/Jukelyn/macOS-Enrollment-Program.git
    cd macOS-Enrollment-Program/
    ```
2.  **Create Virtual Environment:**
    ```bash
    python3 -m venv venv
    ```
3.  **Activate Virtual Environment:**
    ```bash
    source venv/bin/activate
    ```
4.  **Install Dependencies:**
    ```bash
    pip install -r requirements.txt
    ```
    _(Ensure `requirements.txt` exists and lists `customtkinter` and `Pillow`)_
    _OR_ install manually:
    ```bash
    pip install customtkinter Pillow
    ```
5.  **Run the Program:**
    ```bash
    python main.py
    ```

### Additional Steps for Fresh macOS Install

If setting up on a macOS machine without Python or necessary tools:

1.  Install Homebrew from [brew.sh](https://brew.sh/).
2.  Install Python 3 and Tkinter support:
    ```bash
    brew install python python-tk
    ```
3.  Follow the standard installation steps above (Clone, venv, pip install).

## Usage (Intended Deployment via JAMF)

This application is designed primarily to be **deployed and run as a root-level process via a JAMF Pro policy** (e.g., triggered by enrollment completion or user login). End-users should generally not run this application manually outside of specific IT instructions.

When deployed correctly via JAMF, the application will:

1.  Launch automatically in full-screen mode.
2.  Guide the end-user through the prompts:
    - Display an acknowledgement message. The user clicks "Next".
    - Prompt for first and last name entry. The user clicks "Next".
    - Present dropdown menus for Department and Building selection. The user selects options and clicks "Submit".
    - Display a "Submitting Information..." loading screen.
3.  Execute the `jamf recon` command silently in the background using the collected information. **Important:** The user **must** click "Allow" on any macOS prompts requesting permissions for "jamf" or "terminal" if they appear (though running as root via JAMF may suppress some prompts).
4.  Log the submission details to `info_log.txt` (typically created in the directory where the script is run from, e.g., `/Library/Application Support/YourOrg/` depending on JAMF deployment location).
5.  Automatically close upon successful completion of the `jamf recon` command.

## Logging

A record of each submission is appended to the `info_log.txt` file in the application's execution directory. Each entry includes:

- Timestamp (YYYY-MM-DD HH:MM:SS)
- User's Full Name
- Selected Building
- Mapped JAMF Department Group (e.g., `NCSU-COS-MATH`)
- Original Department Name selected by the user

Example Log Entry:
`2025-04-25 13:00:00 - John Doe - SAS Hall - NCSU-COS-MATH (Mathematics)`

## Known Issues & Limitations

- The application assumes the `jamf` binary is located at `/usr/local/bin/jamf`. Deployment will fail if it's located elsewhere.
- Error handling for the `jamf recon` command itself is basic. Failures during the command's execution are printed to `stderr` (visible in JAMF policy logs) but are not explicitly shown to the end-user in the GUI before closing. This is currently by design for a smoother user experience but could be modified.
- The list of buildings and departments in `buildings_departments.txt` must be manually updated as needed.

---

Thank you for using the NC State COS JAMF Enrollment Helper!
