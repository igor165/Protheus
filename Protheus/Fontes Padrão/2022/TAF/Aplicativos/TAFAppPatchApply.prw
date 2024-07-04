#include 'Protheus.ch'
#include 'apwizard.ch'
#include 'fileIO.ch'
#include "fwbrowse.ch"    
#include 'shell.ch'

//-------------------------------------------------------------------
/*/{Protheus.doc} TAFAppPatchApply
Monta interface do app de aplicação de pacotes

@author Fabio V Santana / Luccas Curcio
@since 21/02/2017
@version 1.0 

@aParam 

@return Nil
/*/
//-------------------------------------------------------------------
function TAFAppPatchApply( oWizard , lRet , cFile , nLargLin, cAmbiente, cFileSdf, cUser, cPassword , aIni, cBinPath, lFullPTM, cFilehlp)

Local 	cMaskPatch	
Local	cAlerta		
Local   cPathTDS    
Local   cRootPath   

Local	nLinha		
Local	nColuna		
Local	nAltLinha	
Local	nX			

Local aOpcao 

Local	oPnl1	
Local	oPnl2	
Local	oPnl3	

// --> Váriaveis private para controle dos objetos de tela.
Private	oCbAmb	 
Private	oButton  
Private oGetFile 
Private oGetUsr  
Private oGetPsw	 

cRootPath := AllTrim(GetSrvProfString("RootPath",""))
cPathTDS  := cRootPath + "\Totvs Developer Studio 11.3\"

cPathTDS := StrTran(cPathTDS, "\\", "\")

// Deleta o arquivo de aplicação de patch
If File(cPathTDS + "Patch.bat")
	FErase( cPathTDS + "Patch.bat" )
EndIf

// Deleta o arquivo de visualização do log de patch
If File(cPathTDS + "patchinfo.bat")
	FErase( cPathTDS + "patchinfo.bat" )
EndIf

cMaskPatch	:= ""
cAmbiente 	:= ""
cAlerta		:= ""

nLinha		:= 13
nColuna		:= 14
nAltLinha	:= 10
nX			:= 0	

oPnl1	:= Nil
oPnl2	:= Nil
oPnl3	:= Nil

aOpcao  := {}

Define WIZARD oWizard;
	TITLE 'Assistente de Atualizações.';
	HEADER 'T A F - TOTVS Automação Fiscal';
	MESSAGE "TOTVS Automação Fiscal";			
	TEXT "...ao assistente de atualizações dos ambientes do <b>TOTVS Automação Fiscal.</b><br>"+ ;
	"Para a aplicação de patchs, será necessário preencher as seguintes informações:<br><br>"+;
	"O <b>ambiente</b> onde deseja aplica-la;<br>"+;
	"O <b>caminho</b> onde a patch está localizada;<br>"+;
	"<b>Usuário</b> e <b>Senha</b> do Administrador do sistema. <br><br>"+;
	"Para a atualização do Dicionário de Dados:<br><br>"+;
	"Informe o <b>caminho</b> onde o <b>arquivo diferencial do dicionário de dados(sdf)</b> está localizado.<br>" +;
	"Informe o <b>caminho</b> onde o <b>arquivo diferencial de help</b> está localizado.<br>" +;
	"Será considerado o <b>ambiente</b> preenchido na wizard de <b>aplicação de Patchs.</b><br>"+;
	"Nas Wizards a seguir, preencha os campos conforme orientação acima e clique em avançar.<br>";		 	
	NEXT { || .T. };
	FINISH { || lRet := .T.  };
	NOTESC

CREATE PANEL oWizard;
	HEADER "T A F - TOTVS Automação Fiscal";
	MESSAGE "Preencha corretamente as informações solicitadas...";
	BACK { || .T. };
	NEXT { || TAfVldPatch(cFile, cUser, cPassword, cAmbiente, @lFullPTM) }; 
	FINISH { || lRet := .T. }

	nLinha		:=	13
	nColuna		:=	15
	nAltLinha	:=	10	

	oPnl1		:= 	TPanel():New( 0, 0, , oWizard:oMPanel[ 2 ],, .F., .F.,,, nLargLin, 130, .T., .F. )

	//Carrego a lista de ambientes
	For nX := 1 to Len(aIni)
		If Len(GetPvProfString( aIni[nX], "SourcePath", "",cBinPath,nil,nil)) > 0
			If aIni[nX] <> "PATCH"  
				aAdd(aOpcao,aIni[nX])
			EndIf	
		EndIf
	Next nX

	TSay():New( nLinha, nColuna, { || '<h3>Aplicação de Patch</h3>' }, oPnl1,,,,,, .T., /*CLR_BLUE*/,, nLargLin, nAltLinha,,,,,,.T. )	
	
	nLinha		+=	10

	TSay():New( nLinha, nColuna, { || 'Informar o <b>Usuário Administrador</b>:' }, oPnl1,,,,,, .T., /*CLR_BLUE*/,, nLargLin, nAltLinha,,,,,,.T. )
	nLinha	+=	nAltLinha
	oGetUsr := TGet():New( nLinha, nColuna, {|u| if( PCount()>0, cUser:=u, cUser )}, oPnl1, nLargLin-15, nAltLinha, "@",{||TAFVldAdm(cUser, cPassword, 1)}, 0,,, .F.,, .T.,, .F.,, .F., .F.,, .F., .F.,, cUser,,,, )
	
	nLinha		+=	15
	TSay():New( nLinha, nColuna, { || 'Informar a <b>Senha</b> do Usuário Administrador:' }, oPnl1,,,,,, .T., /*CLR_BLUE*/,, nLargLin, nAltLinha,,,,,,.T. )
	nLinha	+=	nAltLinha
	oGetPsw := TGet():New( nLinha, nColuna, {|u| if( PCount()>0, cPassword:=u, cPassword )}, oPnl1, nLargLin-15, nAltLinha, "@",{||TAFVldAdm(cUser, cPassword, 2)},; 
									0,,, .F.,, .T.,, .F.,, .F., .F.,, .F., .T.,, cPassword,,,, )

	nLinha		+=	15
	TSay():New( nLinha, nColuna, { || 'Informar o <b>Ambiente</b>:' }, oPnl1,,,,,, .T., /*CLR_BLUE*/,, nLargLin , nAltLinha,,,,,,.T. )
	nLinha		+=	nAltLinha
	oCbAmb := TCombobox():New(nLinha,nColuna,{|u| if( PCount()>0, cAmbiente:=u, cAmbiente )},aOpcao,nLargLin-15,nAltLinha,oPnl1,,,,,,.T.,,,,)	
	//TGet():New( nLinha, nColuna, {|u| if( PCount()>0, cAmbiente:=u, cAmbiente )}, oPnl1, nLargLin-15, nAltLinha, "@",, 0,,, .F.,, .T.,, .F.,, .F., .F.,, .F., .F.,, cAmbiente,,,, )				

	nLinha		+=	15

	TSay():New( nLinha, nColuna, { || 'Informe o caminho da <b>patch:</b>' }, oPnl1,,,,,, .T., /*CLR_BLUE*/,, nLargLin, nAltLinha,,,,,,.T. )
	
	nLinha	+=	nAltLinha
	oButton  := TButton():New( nLinha,nColuna,"Buscar",oPnl1,{||cFile:=cGetFile('Patch' + '(*.ptm) |*.ptm|',""),.T.},30,nAltLinha + 2,,,,.T.,.F.,,.T., ,, .F.)			
	oGetFile := TGet():New( nLinha, nColuna + 32, {|u| if( PCount()>0, cFile:=u, cFile )}, oPnl1, nLargLin - 47, nAltLinha, "@",, 0,,, .F.,, .T.,, .F.,, .F., .F.,, .F., .F.,, cFile,,,, )	
	nLinha		+=	nAltLinha

	oButton:Disable()
	oCbAmb:Disable()
	oGetFile:Disable()
	oGetPsw:Disable()
	

CREATE PANEL oWizard;
	HEADER "T A F - TOTVS Automação Fiscal";
	MESSAGE "Preencha corretamente as informações solicitadas...";
	BACK { || .T. };
	NEXT { || .T. }; 
	FINISH { || lRet := .T. }

	nLinha		:=	13
	nColuna		:=	15
	nAltLinha	:=	10	

	oPnl2		:= 	TPanel():New( 0, 0, , oWizard:oMPanel[ 3 ],, .F., .F.,,, nLargLin, 120, .T., .F. )
	
	TSay():New( nLinha, nColuna, { || '<h3>Atualização de Ambiente</h3>' }, oPnl2,,,,,, .T., /*CLR_BLUE*/,, nLargLin, nAltLinha,,,,,,.T. )
	
	nLinha		+=	nAltLinha

	TSay():New( nLinha, nColuna, { || 'Informe o caminho do <b>Arquivo Diferencial do Dicionário de Dados:</b>' }, oPnl2,,,,,, .T., /*CLR_BLUE*/,, nLargLin, nAltLinha,,,,,,.T. )

	nLinha		+=	nAltLinha
	TButton():New( nLinha,nColuna,"Buscar",oPnl2,{||cFileSdf:=cGetFile('(*.txt) |*.txt|',""),.T.},30,nAltLinha + 2,,,,.T.,.F.,,.T., ,, .F.)			
	TGet():New( nLinha, nColuna + 32, {|u| if( PCount()>0, cFileSdf:=u, cFileSdf )}, oPnl2, nLargLin - 47, nAltLinha, "@",, 0,,, .F.,, .T.,, .F.,, .F., .F.,, .F., .F.,, cFileSdf,,,, )	

	nLinha		+=	nAltLinha * 2
	TSay():New( nLinha, nColuna, { || 'Informe o caminho do <b>Arquivo de Help Diferencial:</b>' }, oPnl2,,,,,, .T., /*CLR_BLUE*/,, nLargLin, nAltLinha,,,,,,.T. )
	nLinha		+=	nAltLinha	
	TButton():New( nLinha,nColuna,"Buscar",oPnl2,{||cFilehlp:=cGetFile('(*.txt) |*.txt|',""),.T.},30,nAltLinha + 2,,,,.T.,.F.,,.T., ,, .F.)			
	TGet():New( nLinha, nColuna + 32, {|u| if( PCount()>0, cFilehlp:=u, cFilehlp )}, oPnl2, nLargLin - 47, nAltLinha, "@",, 0,,, .F.,, .T.,, .F.,, .F., .F.,, .F., .F.,, cFilehlp,,,, )

CREATE PANEL oWizard;
	HEADER "T A F - TOTVS Automação Fiscal";
	MESSAGE "Atenção!";
	BACK { || .T. };
	NEXT { || .T. };
	FINISH { || lRet := .T. } 

	nLinha		:=	13
	nColuna		:=	15
	nAltLinha	:=	300	
	oPnl3		:= 	TPanel():New( 0, 0, , oWizard:oMPanel[ 4 ],, .F., .F.,,, nLargLin, 135, .T., .F. )

	cAlerta := "Este programa tem por objetivo compatibilizar o ambiente do cliente em relação as atualizações "
	cAlerta += "referentes ao módulo <b>TOTVS Automação Fiscal.</b><br><br>"

	cAlerta += "Estas atualizações somente poderão ser realizadas em modo <b>EXCLUSIVO!</b><br><br>"

	cAlerta += "Após clicar no botão 'Finalizar', se houver atualização do Dicionário de Dados, <br>"
	cAlerta += "faremos um backup automático do <b>Repositório de Dados. (RPO)</b> <br><br>"
	cAlerta += "Porém é <b>imprescindível</b> que seja feito um backup do Banco de Dados antes da atualização para <br>
	cAlerta += "eventuais falhas no processo.

	cAlerta += '<b><h3 style="color:red;">Alertamos que este é um processo IRREVERSÍVEL, portanto é de extrema importância que os backups sejam realizados.</h3></b>'
	
	TSay():New( nLinha, nColuna, { || cAlerta }, oPnl3,,,,,, .T., /*CLR_BLUE*/,, nLargLin, nAltLinha,,,,,,.T. )

	nLinha		+=	nAltLinha
									
Activate WIZARD oWizard Centered

return

//-------------------------------------------------------------------
/*/{Protheus.doc} PatchApplier
Cria o arquivo .bat que vai aplicar as patch selecionadas

@author Fabio V Santana
@since 21/02/2017
@version 1.0 

@aParam 

@return Nil
/*/
//-------------------------------------------------------------------
Function PatchApplier(cAmbiente  , cFile , cUser , cPassword , lFull )

Local cString   
Local cRootPath 
Local cServer   
Local cBuild 	
Local cPathTDS  
Local cPath     
Local cCommand  
Local cDirArq	
Local cNomeArq	
Local lWait		

Local nHdPatch  
Local nPorta	
Local nPosIni	

cNomeArq := ""
cPath    := ""
cCommand := ""
cDirArq  := ""
lWait	 := .T.
nPosIni	 := 0

cFile := AllTrim(cFile)

If !Empty(cFile)

	nPosIni := Rat( "\", cFile ) + 1

	cNomeArq := SubStr( cFile, nPosIni )

	// Guarda o novo local do arquivo
	// O arquivo já foi copiado para o server na função de análise do patch
	cDirArq	 := "\patch_taf\" + cNomeArq

	cString 	:= ""

	cRootPath 	:= AllTrim(GetSrvProfString("RootPath",""))
	cPathTDS 	:= "\TDS\"
	
	cServer 	:= GetProfString( "TCP", "Server", "", .T. )
	cBuild		:= Substr(GetBuild(.F.),1,At(("-"),GetBuild(.F.))-1)

	nHdPatch 	:= FCreate(cPathTDS + "Patch.bat")
	nPorta		:= Val(GetPvProfString( 'TCP' , 'PORT', '', GetRemoteIniName() , Nil, Nil ))

	If AllTrim(Substr(cFile,1,1)) == '\'
		cFile := cRootPath + cFile
	EndIf

	//--------------------------------------------------------------------------------------------------------------------//
	//                                                     Cria o patch.bat                                              //
	//--------------------------------------------------------------------------------------------------------------------//
	
	//Monto a String de aplicação de patch

	cString += " SET TDS_APPRE=" + cPathTDS + "\" + CRLF			
	cString += " java -jar tdscli.jar patchapply serverType=AdvPL"
	cString += " server=" 		+ AllTrim(cServer)
	cString += " build=" 		+ AllTrim(cBuild)
	cString += " port=" 		+ AllTrim(Str(nPorta))
	cString += " user=" 		+ AllTrim(cUser)
	cString += " psw=" 			+ AllTrim(cPassword)
	cString += " environment=" 	+ AllTrim(cAmbiente)
	cString += " localPatch=F"
	cString += " patchFile=" 	+ AllTrim(cDirArq)
	
	If lFull
		cString += " applyOldProgram=T"
	Else
		cString += " applyOldProgram=F"
	EndIf
	
	cPath    := StrTran(cRootPath + cPathTDS, "\\", "\")
	cCommand := cPath + "patch.bat"
	lWait    := .T.

	If nHdPatch <> -1
		FWrite(nHdPatch, cString)
		FClose(nHdPatch)

		//Executa a bat para aplicar a patch
		//shellExecute( "Open" , cPathTDS + "Patch.bat" , "" , cPathTDS, 1 )
		FWMsgRun(,{|| WaitRunSrv( cCommand , lWait , cPath ) },"Patch.","Aplicando Patch...")
		
		//If MsgYesNo("Deseja reativar o <b>WebService?</b>" + CRLF + "Caso não necessite aplicar outra patch," + CRLF + " recomendamos que reative o Webservice neste momento.","<b>Aplicação de Patch Concluída</b>")
		//	TafOnStart(.F.)		
		//EndIf
		
	Else
		MsgInfo("Não foi possível criar o arquivo facilitador para aplicação de patchs. Verifique suas permissões de gravação em disco.", "Falha!")	
	Endif

EndIf

Return
 
//-------------------------------------------------------------------
/*/{Protheus.doc} UpdApplier
Aplica o update de dicionario de dados

@author Fabio V Santana
@since 14/08/2017
@version 1.0 

@aParam 

@return Nil
/*/
//-------------------------------------------------------------------
Function UpdApplier(cFile , cBinPath , cRemotePath , cAmbiente , cFileHlp ) 

Local cSourcePath 	
Local cDirBkp 		
Local cDirSysLoad 	
Local cDir			
Local cDrive		

Local nAt           

Local lRet          

If !Empty(AllTrim(cFile)) 

	cSourcePath := GetPvProfString( cAmbiente, "SourcePath", "",cBinPath,nil,nil)
	cDirBkp 	:= cSourcePath + "\Bkp_" + Dtos(Date()) + Substring(Time(),1,2) + Substring(Time(),4,2) + Substring(Time(),7,2) + "\"	
	cDirSysLoad := AllTrim(GetPvProfString( cAmbiente, "ROOTPATH", "",cBinPath,nil,nil)) + "\systemload\"

	lRet := .F.

	//Função responsavel por removem os backups do RPO, caso existam mais de 3.
	ClearBackup(cSourcePath)

	//Criação do diretorio de backup do RPO 
	If MakeDir(cDirBkp) == 0

		//Copio o RPO para uma pasta de backp criada no momento da execução
		FWMsgRun(,{||lRet := (_copyfile( cSourcePath + "\tttp120.rpo", cDirBkp + "\tttp120.rpo"))},"Backup do Repositório de Dados.","Realizando Backup do RPO...")

		If !lRet
			If MsgYesNo("Não foi possível realizar o backup do RPO, deseja prosseguir com a atualização?","Falha no BACKUP Automatico!!!")
				lRet := .T.
			EndIf
		EndIf
	EndIf

	If lRet
		//Copio o arquivo sdfbra.txt selecionado na wizard para a pasta systemload
		FWMsgRun(,{||lRet := (_copyfile( cFile, cDirSysLoad + "sdfbra.txt"))},"Copiando arquivo diferencial.","Copiando sdfbra.txt...")

		//Copio o arquivo hlpdfpor.txt selecionado na wizard para a pasta systemload
		FWMsgRun(,{||lRet := (_copyfile( cFileHlp, cDirSysLoad + "hlpdfpor.txt"))},"Copiando Help Diferencial.","Copiando hlpdfpor.txt...")
		SplitPath(cFile,@cDrive,@cDir)

		If File(cDrive + cDir + 'sx2.unq')		
			FWMsgRun(,{||lRet := (_copyfile( cDrive + cDir + 'sx2.unq', cDirSysLoad + "sx2.unq"))},"Copiando arquivo diferencial.","Copiando sx2.unq...")
		EndIf

		If !lRet
			MsgInfo("Não foi possível copiar o arquivo <b>sdfbra.txt</b> na pasta systemload. Verifique suas permissões de gravação em disco.", "Falha!")
		Else

			nAt := At("\smartclient.ini", cRemotePath)
			cRemotePath	:= Substr(cRemotePath,1,nAt)

			shellExecute( "Open" , "Smartclient.exe" , "-m -c='TCP' -q -p='UPDTAF' -a='1' e=" + "'" + cAmbiente + "'" , cRemotePath, 1 )

		EndIF
	EndIF

EndIf	

Return (lRet)

//-------------------------------------------------------------------
/*/{Protheus.doc} ClearBackup

Apaga os backups do RPO.

@author Fabio V Santana
@since 12/09/2017
@version 1.0 

@aParam 

@return Nil
/*/
//-------------------------------------------------------------------
Function ClearBackup(cSourcePath ) 

Local aDirectory 
Local aBackups	 
Local nX         
Local nY         
Local nCount	 	

nCount 	:= 0
nX 		:= 0
nY 		:= 0
aBackups := {}

//Retorna todos os arquivos dentro da pasta APO
aDirectory := Directory(cSourcePath + "\*" ,"D",nil,,2)

//Adiciono a barra ao final do Source Path
If Substr(cSourcePath,Len(cSourcePath),1) <> "\"
	cSourcePath += "\"
EndIf

For nX := 1 to Len(aDirectory) 

	If aDirectory[nX][5] == "D"  .And. Substr(aDirectory[nX][1],1,3) == "BKP" 
		aAdd(aBackups,{aDirectory[nX][1],aDirectory[nX][3],aDirectory[nX][4]})
	EndIf

Next nX

//Se houverem mais de 3 backups, pergunto se o usuario deseja apagar os backups anteriores
If Len(aBackups) > 3
		
	If MsgYesNo("Foram encontrados " + Str(Len(aBackups)) + " backups do Repositório de dados (RPO)." + CRLF + "Deseja <b>remover</b> os backups anteriores e manter somente os 3 últimos?" + CRLF + CRLF + "Caso a resposta seja <b>não</b>, nenhum backup será apagado.","Remover Backups.")

		nCount := Len(aBackups) -3

		For nY := 1 to nCount
			ferase(cSourcePath + aBackups[nY][1]+"\tttp120.rpo")
			DirRemove(cSourcePath + aBackups[nY][1],nil,.F.)
		Next nY

	EndIf

EndIf

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} TAFVldAdm
Valida se a senha digitada para o usuário administrador é valida.
@author  Victor Andrade
@since   13/09/2017
@version 1
/*/
//-------------------------------------------------------------------
Static Function TAFVldAdm(cUsuario, cSenha, nOpc)

Local lRet    
Local aArea   
Local cAuxUsr 
Local cAuxPsw 

lRet    := .T.
aArea   := GetArea()
cAuxUsr := AllTrim(cUsuario)
cAuxPsw := AllTrim(cSenha)

PswOrder(2)

If nOpc == 1
	If !Empty(cAuxUsr)
		If (PswSeek(cAuxUsr, .T. ))
			If !FWIsAdmin( PswID() )
				Alert("Usuário não possui permissão para realizar aplicação de patch.", "Atenção")
				lRet := .F.
			Else
				oGetUsr:Disable()
				oGetPsw:Enable()
				oGetPsw:SetFocus()
			EndIf
		Else
			Alert("Usuário inválido.", "Atenção")
			lRet := .F.
		EndIf
	Else
		MsgAlert("Usuário não foi informado!", "Atenção")
		lRet := .F.
	EndIf
EndIf

If nOpc == 2

	If PswSeek(cAuxUsr, .T. )
		If !PswName(cAuxPsw)
			Alert("Senha inválida!.", "Atenção")
			lRet := .F.
		Else
			// Desabilita os campos de usuário e senha.
			oGetPsw:Disable()

			// Seta o foco botão para quando o usuário dar um "TAB".
			oButton:SetFocus()
				
			// Habilita o campo para preenchimento do arquivo
			oCbAmb:Enable()
			oButton:Enable()
			oGetFile:Enable()

		EndIf
	EndIf

EndIf

RestArea(aArea)

Return(lRet)

//-------------------------------------------------------------------
/*/{Protheus.doc} TAFVldPatch
Mostra o log do patch para usuário, disponibilizando opção para aplicar ou não o patch
@author  Victor Andrade
@since   13/09/2017
@version 1
/*/
//-------------------------------------------------------------------
Static Function TAFVldPatch(cFile, cUser, cPassword, cAmbiente, lFullPTM)

Local cString   
Local cRootPath 
Local cServer   
Local cBuild 	
Local cPathTDS  
Local cFileInfo 
Local cCommand	
Local cPath		
Local cNomeArq	
Local cDirArq	

Local nHdPatch  
Local nPorta	
Local nPosIni	

Local aRet		

Local lRet		
Local lWait		

cDirArq	  := ""
cFileInfo := ""
cCommand  := "" 
cPath     := ""
cNomeArq  := ""
lWait     := .F. 
lRet 	  := .T.
nPosIni	  := 0

If !ExistDir("\log_patch")
	MakeDir("\log_patch")
EndIf

If !ExistDir("\patch_taf")
	MakeDir("\patch_taf")
EndIf

If TAFConnCheck(@lRet)

	If !Empty(cUser)
		
		cFile := AllTrim(cFile)
	
		If !Empty(cFile)
			
			nPosIni := Rat( "\", cFile ) + 1
	
			cNomeArq := SubStr( cFile, nPosIni )
	
			__CopyFile( cFile, "\patch_taf\" + cNomeArq )
	
			// Guarda o novo local do arquivo
			cDirArq	 := "\patch_taf\" + cNomeArq
			
			cString 	:= ""
	
			cRootPath 	:= AllTrim(GetSrvProfString("RootPath",""))
			cPathTDS 	:= "\TDS\"
			
			cServer 	:= GetProfString( "TCP", "Server", "", .T. )
			cBuild		:= Substr(GetBuild(.F.),1,At(("-"),GetBuild(.F.))-1)
	
			// Apaga o arquivo nesse momento, pois o usuário pode selecionar a opção não no MsgYesNo utilizado na função TAFAskPatch()
			// E depois tentar executar novamente, pois o sistema não será derrubado.
			If File(cPathTDS + "patchinfo.bat")
				FErase( cPathTDS + "patchinfo.bat" )
			EndIf
	
			nHdPatch  := FCreate(cPathTDS + "patchinfo.bat")			
			nPorta	  := Val(GetPvProfString( 'TCP' , 'PORT', '', GetRemoteIniName() , Nil, Nil ))
	
			cFileInfo := "log_patch\LOG" + Dtos(dDataBase) + StrTran(SubStr(Time(),1,5),":","") + AllTrim(cUser) + ".txt"

			//Monto a String de aplicação de patch
			cString +=	" SET TDS_APPRE=" + StrTran(cRootPath + cPathTDS, "\\", "\") + CRLF			
			cString += 	" java -jar tdscli.jar patchinfo serverType=AdvPL"
			cString += 	" server=" 		+ AllTrim(cServer)
			cString += 	" build=" 		+ AllTrim(cBuild)
			cString += 	" port=" 		+ AllTrim(Str(nPorta))
			cString += 	" user=" 		+ AllTrim(cUser)
			cString += 	" psw=" 		+ AllTrim(cPassword)
			cString += 	" environment=" + AllTrim(cAmbiente)
			cString += 	" localPatch=F"
			cString += 	" patchFile=" 	+ AllTrim(cDirArq)
			cString += 	" output="		+ cRootPath + cFileInfo
			
			If nHdPatch <> -1
				FWrite(nHdPatch, cString)
				FClose(nHdPatch)
	
				cPath    := StrTran(cRootPath + cPathTDS, "\\", "\")
				cCommand := cPath + "patchinfo.bat"
				lWait    := .T.
	
				If WaitRunSrv( cCommand , lWait , cPath )
					FWMsgRun(,{|| aRet := DetailPatch(cFileInfo, cServer, nPorta, cAmbiente) },"Aguarde...","Analisando Patch...")
					
					lRet 	 := aRet[1]
					lFullPTM := aRet[2]
				Else
					lRet := MsgYesNo("Erro ao analisar o conteúdo do pacote." + Chr(10) + Chr(13) + "Deseja continuar?" )
				EndIf
	
			Else
				MsgInfo("Não foi possível criar o arquivo facilitador para aplicação de patchs. Verifique suas permissões de gravação em disco.", "Falha!")	
				lRet := .F.
			Endif
	
		EndIf
	Else
		MsgAlert("Usuário não foi informado.")
		lRet := .F.
	EndIf

EndIf

Return(lRet)

//-------------------------------------------------------------------
/*/{Protheus.doc} DetailPatch
Aguarda o arquivo de log ser gerado e apresenta na tela para o usuário
@author  Victor Andrade
@since   13/09/2017
@version 1
/*/
//-------------------------------------------------------------------
Static Function DetailPatch(cFileInfo, cServer, nPorta, cAmbiente)

Local lRet	  	
Local lFullPTM	
Local aRet		

lRet	  	:= .F.
lFullPTM	:= .T.
aRet		:= { .F., .T. }

If File(cFileInfo)
	lRet := ViewDetail( cFileInfo, @lFullPTM, cServer, nPorta, cAmbiente )
	aRet[1] := lRet
	aRet[2] := lFullPTM
EndIf

Return(aRet)

//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDetail
Apresenta para o usuário os detalhes do patch
@author  Victor Andrade
@since   13/09/2017
@version 1
/*/
//-------------------------------------------------------------------
Static Function ViewDetail(cFileInfo, lFullPTM, cServer, nPorta, cAmbiente)

Local oDlgPatch 
Local oBrowse	
Local aSize		
Local aAllLines 
Local lRet		

// --> Utilizado no título do browse
cCadastro := "Informações do Patch"

oDlgPatch 	:= Nil
aAllLines	:= FileToArr(cFileInfo, cServer, nPorta, cAmbiente)
aSize		:= MsAdvSize(.F.)
lRet		:= .F.

DEFINE MSDIALOG oDlgPatch FROM aSize[7], 0 TO aSize[4] , ((aSize[5]/2)-100) TITLE "Informações da Patch" PIXEL

DEFINE FWBROWSE oBrowse DATA ARRAY ARRAY aAllLines NO SEEK NO CONFIG NO REPORT Of oDlgPatch

ADD LEGEND DATA {|| !Empty(Dtos(aAllLines[oBrowse:At(),3])) .And.  aAllLines[oBrowse:At(),3] == CTOD(aAllLines[oBrowse:At(),2]) }  COLOR "BLUE"   TITLE "Data do Pacote é igual a do Ambiente"	   Of oBrowse
ADD LEGEND DATA {|| !Empty(Dtos(aAllLines[oBrowse:At(),3])) .And.  aAllLines[oBrowse:At(),3] < CTOD(aAllLines[oBrowse:At(),2]) }   COLOR "GREEN"  TITLE "Data do Pacote é maior que a do Ambiente" Of oBrowse
ADD LEGEND DATA {|| !Empty(Dtos(aAllLines[oBrowse:At(),3])) .And.  aAllLines[oBrowse:At(),3] > CTOD(aAllLines[oBrowse:At(),2]) }   COLOR "RED"    TITLE "Data do Pacote é menor que a do Ambiente" Of oBrowse
ADD LEGEND DATA {|| Empty(Dtos(aAllLines[oBrowse:At(),3])) }   																	   COLOR "YELLOW" TITLE "Não encontrado no Ambiente"    		   Of oBrowse

ADD COLUMN oColumn DATA { || aAllLines[oBrowse:At(),1] }  Title "Programa"      	PICTURE   SIZE 15 Of oBrowse
ADD COLUMN oColumn DATA { || aAllLines[oBrowse:At(),2] }  Title "Data no Patch" 	PICTURE   SIZE 15 Of oBrowse
ADD COLUMN oColumn DATA { || aAllLines[oBrowse:At(),3] }  Title "Data no Ambiente"  PICTURE   SIZE 15 Of oBrowse

ACTIVATE FWBrowse oBrowse

ACTIVATE MSDIALOG oDlgPatch ON INIT EnchoiceBar( oDlgPatch , {|| lRet := TAFAskPatch(aAllLines, @lFullPTM), oDlgPatch:End()} , { || lRet := .F., oDlgPatch:End() },,) CENTERED


Return(lRet)

//-------------------------------------------------------------------
/*/{Protheus.doc} FileToArr
Transforma o arquivo de log em um array
@author  Victor Andrade
@since   13/09/2017
@version 1
/*/
//-------------------------------------------------------------------
Static Function FileToArr(cFileInfo, cServer, nPorta, cAmbiente)

Local oRpcSrv	
Local aAuxLine	
Local aLines	
Local aAllLines 
Local aInfoRPO	
Local aArqInfo	
Local nX		
Local nY		
Local nPosData	
Local nPosFonte	
Local lConnSrv	
Local cData 	
Local cFonte	
Local cLinha	

Local nHndInfo	
Local nTamArq	
Local xBuffer	

Local nHndInfo	:= 0
Local nTamArq	:= 0
Local nX		:= 0
Local xBuffer	:= ''

aArqInfo  := {}
aLines 	  := {}
aAllLines := {}
aInfoRPO  := {}
nX		  := 0
nY		  := 0
nPosData  := 0
nPosFonte := 0
lConnSrv  := .F.
cData     := ''
cFonte    := ''
cLinha	  := ''

//Monta o array com as informações do TXT gerado pelo PATCHINFO
If !Empty(cFileInfo)
	//Leitura do arquivo txt
	nHndInfo :=	FOpen(cFileInfo)
	nTamArq	 :=	FSeek(nHndInfo,0,2)
	xBuffer  := Space(nTamArq)
	
	FSeek(nHndInfo,0,0)
	FRead(nHndInfo,@xBuffer,nTamArq)
	FClose(nHndInfo)

	//Transformação do arquivo em array
	aArqInfo := Str2Arr(xBuffer, chr(10))
EndIf

// Conecta no server onde será aplicado o patch para verificar a data dos fontes.
oRpcSrv := TRpc():New( AllTrim(cAmbiente) )

If ( oRpcSrv:Connect( cServer, nPorta ) )
	lConnSrv := .T.
EndIf

For nY := 1 to len(aArqInfo)

	cFonte := ""
	cData  := ""
	cLinha := aArqInfo[nY]
	nPosFonte := at(".PR",cLinha) 

	If nPosFonte > 1

		cFonte := Substring(cLinha,1,nPosFonte +3)

		nPosData:=  at("/",cLinha) 
		
		If nPosData > 0
			cData := Substring(cLinha,nPosData -2,10)
		EndIf

		aLines := {}

		Aadd(aLines, cFonte)
		Aadd(aLines, cData)
			
		If lConnSrv
			aInfoRPO := oRpcSrv:CallProc("GetAPOInfo", cFonte)

			If Len(aInfoRPO)
				Aadd(aLines, aInfoRPO[4])
			Else
				Aadd(aLines, StoD("") )
			EndIf
		Else
			Aadd(aLines, StoD("") )
		EndIf

		Aadd(aAllLines, aLines)		
	
	EndIf

Next nY	

If lConnSrv
	oRpcSrv:Disconnect()
EndIf

Return(aAllLines)

//-------------------------------------------------------------------
/*/{Protheus.doc} TrimArray
Limpa as posições do array que estão vazias
@author  Victor Andrade
@since   14/09/2017
@version 1
/*/
//-------------------------------------------------------------------
Static Function TrimArray(aAuxLine)

Local nI 	
Local aRet	

aRet := {}
nI := 0

For nI := 1 To Len(aAuxLine)

	If !( Empty(aAuxLine[nI]) )
		Aadd(aRet, aAuxLine[nI] )
	EndIf

Next nI

Return(aRet)

//-------------------------------------------------------------------
/*/{Protheus.doc} TAFAskPatch
Verifica se o patch possui fontes mais antigos que o RPO e pergunta ao usuário se deseja aplicar.
@author  Victor Andrade
@since   14/09/2017
@version 1
/*/
//-------------------------------------------------------------------
Static Function TAFAskPatch(aAllLines, lFullPTM)

Local nX   		
Local nOpcPTM	
Local lRet 		
Local lDateInf	

nX 	 	 := 0
lRet 	 := .T.
lDateInf := .F.

For nX := 1 To Len(aAllLines)
	If !Empty( DTOS(aAllLines[nX][3]) )
		If aAllLines[nX][3] > CTOD(aAllLines[nX][2])
			lDateInf := .T.
			Exit
		EndIf
	EndIf
Next nX

If lDateInf
	nOpcPTM := TAFAviso("Atenção",;
				     "O Ambiente contém programas mais recentes que os existentes no pacote." + Chr(10) + Chr(13) + Chr(10) + Chr(13);
					+ "Selecione abaixo quais fontes deverão ser atualizados.",;
					{"Atualizados", "Todos", "Cancelar"}, 3 )
	If nOpcPTM == 1
		lFullPTM := .F.
	ElseIf nOpcPTM == 2
		lFullPTM := .T.
	Else
		lRet 	 := .F.
	EndIf
	
EndIf

Return(lRet)

//-------------------------------------------------------------------
/*/{Protheus.doc} TAFCheckConn
@author  Fabio V Santana
@since   27/10/2017
@version 1
/*/
//-------------------------------------------------------------------
Function TAFCheckConn(cUrl)

Local cHeaderRet		
Local cPage				
Local cStatus 			
Local cResponse			
Local aHeader			
Local oHttp
Local lRet				

cHeaderRet	:= ""
cPage		:= ""
cStatus		:= ""
cResponse	:= "200"
aHeader   	:= {"Content-Type: application/json"}
oHttp       := FWHttpHeaderResponse():New()
lRet		:= .F.

//--Faz get na API
cPage := HttpGet(cUrl,,,aHeader,@cHeaderRet) 

//-- Verifica se houve response.
If !Empty(cHeaderRet)
	oHttp:Activate(cHeaderRet)
	//-- Captura o Status do request
	cStatus := oHttp:getStatusCode()
	If ValType(cStatus) == "C"
		If Alltrim(cStatus) == Alltrim(cResponse)
			lRet := .T.
		EndIF
	EndIF
Else
	lRet := .F.
EndIf

//-- Libera a memoria do Objeto
oHttp:GetReason()

Return(lRet)

//-------------------------------------------------------------------
/*/{Protheus.doc} TAFConnCheck
@author  Denis Souza
@since   20/12/2018
@version 1
/*/
//-------------------------------------------------------------------

Function TAFConnCheck( lRet  )

Local cJobName			
Local cPrepIn			
Local cBinPath			
Local cRemotePath		
Local cConexao			
Local cServerPath		
Local aPrepIn			
Local nX				
Local nY				
Local nCount			
Local nAt				

cRemotePath	:=  GetRemoteIniName()
nAt 	 	:=  At('\BIN',Upper(cRemotePath))
cBinPath 	:=  Substr(cRemotePath,1,nAt) + 'bin\app\appserver.ini'
cServerPath	:=  Substr(cRemotePath,1,nAt) + 'bin\serverpatch\appserver.ini'
cJobName    := "TAF_ACCEPT"
cConexao	:= "PATCH_WS"
cPrepIn	    := ""
nCount	    := 0
nX		    := 0
nY		    := 0
aPrepIn	    := {}

oRpcSrv := TRpc():New( "TAF_WS" )

//Verifico a existencia da nova estrutura com 3 servers
If File(cServerPath)
	cConexao := "WS"
EndIf

If (oRpcSrv:Connect( GetPvProfString( cConexao, 'Server', '', GetRemoteIniName() , Nil, Nil ), Val(GetPvProfString( cConexao , 'PORT', '', GetRemoteIniName() , Nil, Nil )) ))

	//Recupera as empresas da sessão preparein do webservice
	cPrepIn := GetPvProfString( 'TAF_CFGJOB', 'PrepareIn', '', cBinPath , Nil, Nil )

	//Caso a configuração de empresas seja igual a ALL ou branco, pego as informações do SIGAMAT,
	//senao utilizo a chave configurada
	If Alltrim(UPPER(cPrepIn)) != 'ALL' .Or. AllTrim(cPrepIn) != ""
		aPrepIn := SEPARA(cPrepIn,',',.f.)
	Else
		cPrepIn := ''
		OpenSm0(,.T.)
		While SM0->(!Eof())
			cPrepIn += SM0->M0_CODIGO + ','
			SM0->(dbSkip())
		EndDo
		aPrepIn := SEPARA(cPrepIn,',',.f.)
	EndIf

	For nx := 1 to Len(aPrepIn)
		cJobName :=	cJobName + "_" + aPrepIn[nX]
		If (oRpcSrv:CallProc("IPCCount", cJobName )) > 0
			nCount += 1
		EndIf
	Next nX

	//Valido as informações caso o REST esteja na estrutura anterior sem o nome do grupo de empresas
	nX := 0
	cJobName    := "TAF_ACCEPT"

	For nx := 1 to Len(aPrepIn)
		If (oRpcSrv:CallProc("IPCCount", cJobName )) > 0
			nCount += 1
		EndIf
	Next nX

	//Se o contador de conexoes retornar mais do que 1, existe uma conexão ativa
	If nCount > 0
		If File(cServerPath)
			Aviso('Atenção!', 'O WebService está em execução.' + CRLF + CRLF +;
					'Para a correta utilização do TAF Atualizador, o serviço TAF-WS deve ser encerrado manualmente.' + CRLF +;
					'Para maiores informações sobre a reinicialização do serviço, consulte a documentação do instalador do TAF no portal TDN.',{'Ok'},3)
		Else
			Aviso('Atenção!','O WebService está em execução.' + CRLF + CRLF +;
			 'Para a correta utilização do TAF Atualizador, iremos desativar o WebService momentaneamente.' + CRLF +; 
	 		 'Porém para que a conexão seja encerrada completamente, será necessário reiniciar o serviço TAF-WS manualmente.' + CRLF +;  
	 		 'Para maiores informações sobre a reinicialização do serviço, consulte a documentação do instalador do TAF no portal TDN.',{'Ok'},3)
			TafOnstart(.T.)
		EndIf
		lRet := .F.
	Else
		lRet := .T.
	EndIf
	oRpcSrv:Disconnect()
Else
	lRet := .T.
EndIf

Return(lRet)

//-------------------------------------------------------------------
/*/{Protheus.doc} TAFOnStart
@author  Fabio V Santana
@since   27/10/2017
@version 1
/*/
//-------------------------------------------------------------------
Function TAFOnStart(lApaga)

Local cIniFile 
Local cOldJobs 

cIniFile :=	getAdv97()
cOldJobs := ""

If lApaga
	DeleteKeyIni( 'OnStart', 'JOBS', cIniFile )
Else
	//verifica a necessidade de incluir HTTPJOB na chave JOBS da seção [OnStart]
	if !( 'HTTPJOB' $ getPvProfString( 'OnStart' , 'JOBS' , '' , cIniFile ) )
		
		//guardo os jobs já configurados no ambiente e adiciono o HTTPJOB
		cOldJobs := getPvProfString( 'OnStart' , 'JOBS' , '' , cIniFile )
		cOldJobs += iif( !empty( cOldJobs ) , ',HTTPJOB' , 'HTTPJOB' )
		
		writePProString( 'OnStart' , 'JOBS' 		, cOldJobs 		, cIniFile )
		
		//crio a chave de RefreshRate apenas se não existir
		if empty( getPvProfString( 'OnStart' , 'RefreshRate' , '' 	, cIniFile ) )
			writePProString( 'OnStart' , 'RefreshRate' 	, '120'		, cIniFile )
		endif
		
	endif
	
	//verifica a necessidade de incluir TAF_CFGJOB na chave JOBS da seção [OnStart]
	if !( 'TAF_CFGJOB' $ getPvProfString( 'OnStart' , 'JOBS' , '' , cIniFile ) )
		
		//guardo os jobs já configurados no ambiente e adiciono o HTTPJOB
		cOldJobs := getPvProfString( 'OnStart' , 'JOBS' , '' , cIniFile )
		cOldJobs += iif( !empty( cOldJobs ) , ',TAF_CFGJOB' , 'TAF_CFGJOB' )
		
		writePProString( 'OnStart' , 'JOBS' 		, cOldJobs 		, cIniFile )
		
		//crio a chave de RefreshRate apenas se não existir
		if empty( getPvProfString( 'OnStart' , 'RefreshRate' , '' 	, cIniFile ) )
			writePProString( 'OnStart' , 'RefreshRate' 	, '120'		, cIniFile )
		endif
	
	endif
EndIf

Return
