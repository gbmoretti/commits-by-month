class Interface
  def self.ask_login
    p "Enter your GitHub username"
    gets.chomp
  end

  # No-echo password input, stolen from Defunkt's `hub`
  # Won't work in Windows
  def self.ask_password
    p "Enter your GitHub password (this will NOT be stored)"
    tty_state = `stty -g`
    system 'stty raw -echo -icanon isig' if $?.success?
    pass = ''
    while char = $stdin.getbyte and not (char == 13 or char == 10)
      if char == 127 or char == 8
        pass[-1,1] = '' unless pass.empty?
      else
        pass << char.chr
      end
    end
    pass
  ensure
    system "stty #{tty_state}" unless tty_state.empty?
  end

end