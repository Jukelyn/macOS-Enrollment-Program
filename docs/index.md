# Prerequisites

1. Homebrew (preferred)
2. Python3 and Tkinter (`brew install python3 python-tk`)

# Instructions

```bash
brew install python3 python-tk # Installs Python and Tkinter

python3 -m venv venv # Creates the virtual enviornment

source venv/bin/activate # Activates the virtual enviornment

pip install -r requirements.txt # Installs dependencies for the program

python main.py # Runs the program.
```

This project was made possible by Mehraz Ahmed with the help of Imraan Khan.

This GUI tool, designed for NC State COS, is used for JAMF enrollment.

The program uses the CustomTkinter library to display a series of pages:

1. **Acknowledgement Page**: A message asking the user to acknowledge and
   proceed with the input process.

2. **Name Input Page**: Prompts the user to enter their first and last names.

3. **Department and Building Selection Page**: Allows the user to select their
   department and building from predefined dropdown options.

4. **Save and Submit**: After gathering the necessary information, the data is
   saved into a text file.

Key notes:

- The GUI elements (labels, entry fields, dropdowns, buttons) are dynamically
  scaled based on a scaling factor for better accessibility.
- Data is currenly saved in a text file with a timestamp and the user's input.
- The program is intended for use on macOS with Python v3.9 or higher.

The program also includes helper functions for refreshing the window, clearing
widgets, and centering the window on the screen.

Dependencies:

- CustomTkinter for the GUI components.
- Pillow for image processing (background and banner images)
- Callable for typehinting
- strftime and subprocess for handling time formatting and executing system
  commands.