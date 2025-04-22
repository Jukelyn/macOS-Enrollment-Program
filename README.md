# macOS Enrollment Program

<!-- The full documentation can be found [here on GitHub Pages](https://pages.github.ncsu.edu/Mathematics/macOS-Enrollment-UI/). -->

This program provides a GUI for gathering user input for enrollment.

The program uses the CustomTkinter library to display a series of pages:

1. **Acknowledgement Page**: A message asking the user to acknowledge and
   proceed with the input process.

2. **Name Input Page**: Prompts the user to enter their first and last names.

3. **Department and Building Selection Page**: Allows the user to select their
   building and department from predefined dropdown options.

4. **Save and Submit**: After gathering the necessary information, the data is
   saved into a text file.

Key notes:

- The GUI elements (labels, entry fields, dropdowns, buttons) are dynamically
  scaled based on a scaling factor for better accessibility.
- Data is currenly saved in a text file with a timestamp and the user's input.
- The program is intended for use on macOS with Python versions 3.9 through 3.12

The program also includes helper functions for refreshing the window, clearing
widgets, and centering the window on the screen.

Dependencies:

- CustomTkinter for the GUI components.
- Pillow for image processing (background and banner images)
- Callable for typehinting
- strftime and subprocess for handling time formatting and executing system
  commands.

This project was made possible by Mehraz Ahmed with the help of Imraan Khan.

# Instructions

- `python3 -m venv venv` - Creates the virtual enviornment
- `source venv/bin/activate` - Activates the virtual enviornment
- `pip install -r requirements.txt` - Installs dependencies for the program
- `python main.py` - Runs the program.

## Additional Steps (fresh install macOS)

- Install homebrew from brew.sh
- brew install python3 python-tk
- Follow the above instructions


## TODO

- [ ] Make a screen that shows this is mandatory
- [ ] Add a screen to tell ppl to click allow for the popups
