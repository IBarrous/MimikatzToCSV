# MimikatzToCSV
<h3>Description : </h3>
a custom powershell script designed to parse the content of Mimikatz and Export it as CSV file.
<h3>Usage :</h3>
<pre><code>.\MimikatzToCSV.ps1 [-InputFile] <string> [-OutputFile] <string> [-Vault] [-Help]</code></pre>
<h3>Options :</h3>
<ul>
  <li> -InputFile <string> : The path to the Mimikatz output text file to be parsed.</li>
  <li> -OutputFile <string> : The path to the CSV file where the parsed credentials will be saved.</li>
  <li> -Vault : A switch to indicate if the input file contains vault::cred output. If this switch is set, the script will parse vault::cred credentials.</li>  
  <li> -Help : A switch to display this help message.</li>
</ul>
<h3>Details :</h3>
The script reads a Mimikatz output file, extracts relevant credential information (Usernames, SIDs, Domains, PlainText Passwords, Encrypted Passwords, Vault Credentials), and exports it to a specified CSV file. It supports parsing both sekurlsa::ekeys and vault::cred outputs, controlled by the -Vault switch.
<br />
<br />
<p align="center"><i>Example of a Parsed Mimikatz Vault Output</i></p>

<div align="center">
  <img src="https://github.com/IBarrous/MimikatzToCSV/assets/126162952/5867e969-f03b-4a6b-9df4-b819738c9306" alt="image1">
</div>
