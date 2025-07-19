# MCORE GERALD HEIST

FiveM resource for a Gerald mission. Supports both ESX and QBCore frameworks, uses ox_lib and lation_ui for notifications and target systems.

## Installation
1. Upload the resource to your server's `resources` folder.
2. Add dependencies to your server.cfg:
   - ox_lib
   - lation_ui
3. Add the following line to your server.cfg:
   ```
   ensure mcr-gerald
   ```

## Dependencies
- [ox_lib](https://github.com/overextended/ox_lib)
- [lation_ui](https://github.com/lation-dev/lation_ui)

## Security
- All server events use only the `source` variable for player identification, never trusting client-sent IDs.
- Simple anti-spam cooldown (10 seconds per action) is implemented for all sensitive events.
- Suspicious attempts (e.g., spamming events) are logged to the server console.
- The `deliverVehicle` event contains a placeholder for further validation (e.g., player position, vehicle check).

## License

This project is licensed under the MIT License:

```
MIT License

Copyright (c) 2025 MCore Development

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
``` 