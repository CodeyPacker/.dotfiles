## Dot Files for Mac OS
- The .dotfiles package was created to configure the same environment on multiple devices. When changes are applied, push them to the repository so that other devices can automatically take advantage of those changes.

### Installation
1. Clone repo into the home directory

    ```
    cd ~ && git clone https://github.com/codeypacker/.dotfiles.git
    ```
3. Navigate to the .dotfiles directory and run the installation file
   
    ```
    cd ~/.dotfiles && sh install.sh
    ```
5. Set MesloLGS NF Font in iTerm2
    1. Open iTerm2.
    2. Open iTerm2 Settings.
    3. Navigate to Profiles -> Text
    4. Change font to MesloLGS NF
    
### ZSH
- ```ZSH``` is configured to use ```iTerm2```, ```Oh-My-Zsh```, and ```Powerlevel10k```. 
- If you want to change the ```Powerlevel10k``` settings, update the ```.zshrc``` file and then execute the following command in the terminal

    ```
    p10k configure
    ```

### Neovim
- ```Neovim``` is automaticly installed and configured with ```lua```. 
- ```Vim``` has been remapped to use ```Neovim```, so no need to type ```nvim```.
