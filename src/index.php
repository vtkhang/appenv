<?php
echo "<h1>PHP Environment Test</h1>";
echo "<h2>PHP Version: " . phpversion() . "</h2>";
echo "<h3>Server Software: " . $_SERVER['SERVER_SOFTWARE'] . "</h3>";
phpinfo();
?>
