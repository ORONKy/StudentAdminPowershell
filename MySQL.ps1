function runSql($database, $sql) {
	if ( $global:connection -eq $null ) {
		[void][System.Reflection.Assembly]::LoadWithPartialName("MySql.Data")
		$pass = ""
		$connectionString = "server=localhost;port=3306;uid=root;pwd="+$pass+";database="+$database
		$global:connection = New-Object MySql.Data.MySqlClient.MySqlConnection($connectionString)
		$global:connection.Open()
	}
	$command = New-Object MySql.Data.MySqlClient.MySqlCommand($sql, $global:connection)
	$dataAdapter = New-Object MySql.Data.MySqlClient.MySqlDataAdapter($command)
	$data = New-Object System.Data.DataTable
	$recordCount = $dataAdapter.Fill($data)
	return $data
}

