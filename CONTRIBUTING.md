# Contributing to Itachi

Thank you for your interest in contributing to Itachi! We welcome contributions from developers of all skill levels.

## Getting Started

### Prerequisites
- A web browser (Chrome, Firefox, Safari, Edge)
- A text editor or IDE (VS Code, Sublime Text, etc.)
- Git
- Node.js (optional, for running a local dev server)

### Development Setup

1. **Fork the repository:**
   ```bash
   git clone https://github.com/your-username/Itachi.git
   cd Itachi
   ```

2. **Run a local server (optional):**
   ```bash
   # Using Python 3
   python -m http.server 8000
   
   # Using Node.js
   npx http-server
   
   # Using PHP
   php -S localhost:8000
   ```

3. **Open in browser:**
   Navigate to `http://localhost:8000` and open `Intex.html`

## Code Standards

### JavaScript Guidelines
- Use ES6+ syntax (arrow functions, const/let, destructuring, template literals)
- Write clear, descriptive variable names: `backgroundColor` not `bgc`
- Keep functions small and focused (aim for <50 lines)
- Add comments only when the code logic isn't obvious
- Use const by default, let when needed, avoid var

### Example Code Style
```javascript
// ✅ Good
const selectColor = (colorName) => {
  activeColor = COLORS.find(c => c.name === colorName);
  updateUI();
};

// ❌ Avoid
var color;
function selectColor(name) {
  // Find color
  for(let i = 0; i < COLORS.length; i++) {
    if(COLORS[i].name == name) {
      color = COLORS[i];
      updateUI();
    }
  }
}
```

### CSS Guidelines
- Use CSS custom properties (CSS variables) for colors and sizing
- Keep selectors specific but not overly nested
- Use meaningful class names: `.cube-board`, not `.cb`
- Mobile-first approach: start with mobile styles, use media queries for larger screens

### HTML Guidelines
- Use semantic HTML5 elements (header, nav, main, section, article, footer)
- Add data attributes for JavaScript targeting: `data-color-id`, `data-sticker-index`
- Always include alt text for images

## Commit Message Format

Format your commits clearly and descriptively:

```
Type: Brief description (50 chars max)

Detailed explanation if needed (wrap at 72 chars).

Fixes #123
```

**Types:**
- `feat` - A new feature (new solver algorithm, UI improvement)
- `fix` - Bug fix (incorrect cube rotation, color picker issue)
- `docs` - Documentation changes (README, comments)
- `style` - Code style changes (formatting, CSS refactoring)
- `refactor` - Code restructuring without behavior change
- `perf` - Performance improvements
- `test` - Adding or updating tests

**Examples:**
```
feat: Add cube rotation animation
docs: Update installation instructions
fix: Correct U-face clockwise rotation
```

## Testing Your Changes

### Before Submitting a PR
1. **Test in multiple browsers:** Chrome, Firefox, Safari (if available)
2. **Test on mobile:** Use browser dev tools to simulate mobile devices
3. **Test all features:**
   - Set colors and verify they persist correctly
   - Scramble cubes and verify randomness
   - Solve cubes and verify solutions
   - Step through solutions and verify move application
   - Test on small screens and verify responsive behavior

### Manual Testing Checklist
- [ ] Tested in Chrome/Firefox/Safari
- [ ] Tested on mobile view (320px, 768px, 1024px)
- [ ] Color picker works correctly
- [ ] Scramble generates valid cube states
- [ ] Solver produces correct solutions
- [ ] No console errors in dev tools
- [ ] All buttons are clickable and functional

## Submitting a Pull Request

### Creating a PR

1. **Create a feature branch:**
   ```bash
   git checkout -b feature/your-feature-name
   ```

2. **Make your changes:**
   - Keep changes focused on one feature
   - Follow code standards above
   - Test thoroughly

3. **Commit with clear messages:**
   ```bash
   git add .
   git commit -m "feat: Your feature description"
   ```

4. **Push to your fork:**
   ```bash
   git push origin feature/your-feature-name
   ```

5. **Open a Pull Request** with:
   - Clear title: "Add cube rotation animation"
   - Description explaining what and why
   - Screenshots showing the feature (if UI change)
   - Reference to any related issues: "Fixes #42"

### PR Title Format
- ✅ "Add color picker feature"
- ✅ "Fix cube rotation bug"
- ✅ "Update README with API docs"
- ❌ "Fix stuff"
- ❌ "Updates"

### PR Description Template
```markdown
## Description
Brief description of the change.

## Type of Change
- [ ] Bug fix
- [ ] New feature
- [ ] Documentation
- [ ] Code refactor

## Testing
How did you test this? What browsers/devices?

## Screenshots (if applicable)
Show before/after for UI changes.

## Checklist
- [ ] Code follows style guidelines
- [ ] Tested on multiple browsers
- [ ] Tested on mobile view
- [ ] Comments added for complex logic
- [ ] No console errors
```

### Review Process
- At least one maintainer will review
- They may request changes or clarifications
- Address feedback promptly
- Once approved, PR will be merged

## Issues and Feature Requests

### Reporting a Bug

Include:
- Clear title and description
- Steps to reproduce
- Expected vs. actual behavior
- Browser and OS information
- Screenshots if applicable

### Suggesting a Feature

Include:
- Use case and benefit
- How it fits with the project
- Possible implementation approach
- Mockups/sketches if UI-related

## Code of Conduct

- Be respectful and inclusive
- Welcome diverse perspectives
- Focus on ideas, not people
- Report harassment to maintainers

## Questions?

- 📖 Check the [README](README.md) first
- 💬 Open an issue to ask questions
- 🐛 Report bugs in the Issues tab

## Recognition

All contributors will be recognized in:
- The main README
- Release notes for your changes
- GitHub contributors page

Thank you for making Itachi better! 🎉
