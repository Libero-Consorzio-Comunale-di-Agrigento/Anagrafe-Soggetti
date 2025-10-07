eventTestPhaseStart = {
	name -> junitReportStyleDir = 'test/conf'
}

eventTestPhaseEnd = {
	println "*** Moving screenshots for JUnit Attachment Jenkins Plugin"
	File src = new File("target/test-reports/screenshots/it/finmatica/anagrafica/test/AnagraficaSpec")
	if (src.exists()) {
		File dst = new File("target/test-reports/it.finmatica.anagrafica.test.AnagraficaSpec"); 
		boolean fileMoved = src.renameTo(dst)
		File srcParent = new File("target/test-reports/screenshots")
		//def screenshotsDir = new File("target/test-reports/screenshots")
		//FileSystemUtils.deleteRecursively(screenshotsDir)
	}
}