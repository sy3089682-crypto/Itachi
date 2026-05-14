# Itachi - Rubik's Cube Solver

![License](https://img.shields.io/badge/license-MIT-blue)
![JavaScript](https://img.shields.io/badge/JavaScript-ES6+-yellow)
![Build Status](https://img.shields.io/badge/build-passing-brightgreen)

A powerful, interactive web-based Rubik's Cube solver with step-by-step solutions. Built with vanilla JavaScript and the Cube.js solver library.

## Features

- **Interactive 3D Cube Visualization** - Click to set sticker colors and build any cube state
- **Automated Solving** - Uses advanced algorithms to find optimal solutions
- **Step-by-Step Instructions** - Navigate through solution moves one at a time
- **Random Scrambler** - Generate random cube states to practice solving
- **Color Picker** - Easy-to-use interface for setting cube colors
- **Responsive Design** - Works on desktop and mobile devices
- **Real-time Visualization** - See each move applied to the cube immediately

## Tech Stack

- **Frontend:** Vanilla JavaScript (ES6+)
- **Solver:** Cube.js library (https://rubik-js.com/)
- **Styling:** CSS3 with responsive grid layout
- **Architecture:** Single-page application (SPA)

## Installation

### Clone the Repository
```bash
git clone https://github.com/your-username/Itachi.git
cd Itachi
```

### Local Development

Simply open the HTML file in a web browser:

```bash
# Using Python 3
python -m http.server 8000

# Or using Node.js
npx http-server

# Or using PHP
php -S localhost:8000
```

Then navigate to `http://localhost:8000` and open `Intex.html`

## Usage

### Setting Up a Cube State

1. **Select a Color:** Click on a color swatch at the top to select the active color
2. **Click Stickers:** Click on any sticker on the cube board to paint it with the selected color
3. **Or Scramble:** Click "Random Scramble" to generate a random cube state

### Solving the Cube

1. **Click Solve:** Press the "Solve" button to calculate the solution
2. **View Moves:** The solution will appear as move notation (e.g., "R", "U'", "D2")
3. **Step Through:** Use "Previous" and "Next" buttons to navigate through solution steps
4. **Reset:** Click "Reset (solved)" to return to a solved cube state

### Cube Notation

- **U** - Up face (clockwise)
- **R** - Right face (clockwise)
- **F** - Front face (clockwise)
- **D** - Down face (clockwise)
- **L** - Left face (clockwise)
- **B** - Back face (clockwise)
- **'** - Prime (counter-clockwise)
- **2** - Double turn (180°)

## Project Structure

```
Itachi/
├── Intex.html          # Main application entry point
├── app.jss             # Core solver logic and DOM interactions
├── Styles.css          # Application styling
├── package.json        # Project metadata
└── README.md           # This file
```

## Development

### Code Style

- Use ES6+ features (arrow functions, const/let, destructuring)
- Follow naming conventions: camelCase for variables/functions, UPPER_CASE for constants
- Add comments for complex logic
- Keep functions focused and modular

### Testing

To test the application:

1. Open the browser developer tools (F12)
2. Test cube operations: scrambling, solving, color picking
3. Test on different screen sizes for responsive behavior
4. Check browser console for any errors

## Contributing

Contributions are welcome! Please see [CONTRIBUTING.md](CONTRIBUTING.md) for guidelines.

### Quick Start for Contributors

1. Fork the repository
2. Create a feature branch: `git checkout -b feature/your-feature`
3. Make your changes and test thoroughly
4. Commit with a clear message: `git commit -m "feat: description"`
5. Push to your fork and submit a pull request

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Acknowledgments

- [Cube.js](https://rubik-js.com/) - Excellent Rubik's cube solving library
- Inspired by competitive speedcubing community

## Support

- 📋 [Issues](https://github.com/your-username/Itachi/issues) - Report bugs or request features
- 💬 [Discussions](https://github.com/your-username/Itachi/discussions) - Ask questions and share ideas

---

**Made with ❤️ for cube enthusiasts everywhere**
