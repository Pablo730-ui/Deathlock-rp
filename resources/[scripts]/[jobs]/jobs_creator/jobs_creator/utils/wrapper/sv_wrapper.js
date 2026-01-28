exports('SaveResourceFile', (path, data)=>{
	if(!path || !data) return false
	const fs=require('fs')
	try {
		fs.writeFileSync(path, data, 'utf8')
	} catch(e){
		console.error(e)
		console.error('Failed to save resource file: ' + path)
		return false
	}
	console.log('Resource file saved: ' + path)
	return true
})