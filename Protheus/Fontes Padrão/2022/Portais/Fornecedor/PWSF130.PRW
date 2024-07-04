//O código abaixo representa o arquivo "Pwsf130.PRW", que contém as funções escritas em ADVPL ASP.-->
#INCLUDE "PROTHEUS.CH"
#INCLUDE "FILEIO.CH"
#INCLUDE "APWEBEX.CH"

#INCLUDE "TBICONN.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "FWADAPTEREAI.CH"

#DEFINE NOPER_INCLUSAO	3

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o      ³ PWSF130³ Autor ³ José Eulálio                ³ Data ³ 31/03/16 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Programador ³ Data   ³ BOPS       ³  Motivo da Alteracao                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Oswaldo L   ³21/12/17³DRHPAG-9991 ³Tratar acessos diretos na SX2, pontuados  ³±±
±±³            ³        ³            ³pelo sonarqube                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/ 


//-------------------------------------------------------------------
/*/{Protheus.doc}Pwsf131
Realiza a chamada do html

@author José Eulálio
@since 20/02/2015
@version P12.1.5
/*/
//-------------------------------------------------------------------
Web Function Pwsf131()
//Web Function Upload()
Local cHtml 	:= ""
Local aEntida	:= Array(2)
Local cForNome	:= ""
Local cItemGrd	:= ""
Local cValid	:= ""
Local cEmpPF	:= HTTPSESSION->PWSF063RESULT[1][1]:OWSQUOTEITEM:OWSQUOTEITEMVIEW[1]:cCode
Local cFilPF	:= HTTPSESSION->PWSF063RESULT[1][1]:OWSQUOTEITEM:OWSQUOTEITEMVIEW[1]:cBranch
Local cPropos   := HTTPSESSION->PWSF063RESULT[1][1]:OWSQUOTEITEM:OWSQUOTEITEMVIEW[1]:cProposAlid
Local ni		:= 0

If Empty(HTTPSESSION->PWSF131EMPFIL)
	HTTPSESSION->PWSF131EMPFIL := {cEmpPF,cFilPF}
	PREPARE ENVIRONMENT EMPRESA cEmpPF FILIAL cFilPF MODULO "COM" TABLES "ACB","AC9","ACC"
EndIf

If	HttpPost->cCotacao <> Nil
	HttpSession->cCotacao   := HttpPost->cCotacao
EndIf

HttpSession->PWSF131APH := 	{ 	TamSX3("ACB_OBJETO")[1],; 	//tamanho do campo
									"",;							//motivo do retorno falso
									"",;							//nome do arquivo
									"";								//extensão do arquivo
								}
								
HttpSession->PWSF131RESULT := 	{  }

WEB EXTENDED INIT cHtml START "InSite"

cForNome	:= Posicione('SC8',1,HTTPSESSION->PWSF131EMPFIL[2] + HttpSession->cCotacao + HttpSession->CODFORERP, "C8_FORNOME")
cItemGrd	:= SC8->C8_ITEMGRD

aEntida[1] := cFilPF + HttpSession->cCotacao + HttpSession->PWSF063APH[3] + cItemGrd + HttpSession->CODFORERP + cPropos + cFornome
aEntida[2] := cFilPF + HttpSession->cCotacao + HttpSession->PWSF063APH[3] + cItemGrd

DbSelectArea("AC9")
AC9->(DbSetOrder(2))

For ni := 1 To len(aEntida)
	If AC9->(DbSeek( xFilial("AC9") + "SC8" + cFilPF + AllTrim(aEntida[nI]) ))
		cQuebra := cFilPF + aEntida[nI]
		While !(AC9->(Eof())) .And. ( AllTrim(cQuebra) == AllTrim(cFilPF + aEntida[nI]))
			cValid := AC9->AC9_CODENT
			If  AllTrim(cValid) == AllTrim(aEntida[nI])
				If ACB->(DbSeek( xFilial("ACB") + AC9->AC9_CODOBJ ))
					If empty(HttpSession->PWSF131RESULT) .Or. aScan(HttpSession->PWSF131RESULT, {|x| AllTrim(x[2])==AllTrim(AC9->AC9_CODOBJ)}) < 1  
						Aadd(HttpSession->PWSF131RESULT,{ ACB->ACB_FILIAL, ACB->ACB_CODOBJ, ACB->ACB_OBJETO, ACB->ACB_DESCRI } ) 
					EndIf
				EndIf
			EndIf
			AC9->(DbSkip())
			cQuebra := AC9->(AC9_FILENT + AC9_CODENT)		
		EndDo
	EndIf
EndFor

HttpSession->PWSF131DWL	:= ""

cHtml += ExecInPage( "PWSF131" )

WEB EXTENDED END

Return cHtml

//-------------------------------------------------------------------
/*/{Protheus.doc}Pwsf130UpF
Realiza upload de arquivo para o banco de conhecimento da cotação

@author José Eulálio
@since 20/02/2015
@version P12.1.5
/*/
//-------------------------------------------------------------------
Web Function Pwsf130UpF()
Local nH := FOpen( httpPost->txtFile, 0 + 64 )
Local aRecs := {}
Local cHtml
Local cEmpPF
Local cFilPF
Private LengthFile := 0

If Type("cFilAnt") == "U" .Or. Empty(HTTPSESSION->PWSF131EMPFIL)
	cEmpPF	:= HTTPSESSION->PWSF063RESULT[1][1]:OWSQUOTEITEM:OWSQUOTEITEMVIEW[1]:cCode
	cFilPF	:= HTTPSESSION->PWSF063RESULT[1][1]:OWSQUOTEITEM:OWSQUOTEITEMVIEW[1]:cBranch
	PREPARE ENVIRONMENT EMPRESA cEmpPF FILIAL cFilPF MODULO "COM" TABLES "ACB","ACB","ACC"
EndIf

LengthFile := fSeek( nH, 0, FS_END )

If Type( "nModulo" ) == "U"
	nModulo := 2 
EndIf

//Realiza a cópia do arquivo
lRet := W_PWSF130Cpy( httpPost->txtFile )

If lRet
	//cHtml += ExecInPage( "UPLOAD" )
	cHtml += ExecInPage( "W_PWSF060" )
EndIf

Return cHtml

//-------------------------------------------------------------------
/*/{Protheus.doc}PWSF130Cpy
Copia o Objeto para a pasta de destino

@author José Eulálio
@since 20/02/2015
@version P12.1.5
/*/
//-------------------------------------------------------------------
Web Function PWSF130Cpy( cGetFile )
Local cDirDocs		:= ""
Local cFile			:= ""
Local cExten		:= ""     
Local cNameTerm		:= ""
Local cNameServ		:= ""
Local cEntidade		:= "SC8"
Local cUnico		:= ""
Local CodEnt		:= ""
Local cCodDesc		:= ""
Local nScan			:= 0
Local nLenACBDes	:= 60


Local aEntidade	:= {}
Local aChave		:= {}
Local aRet			:= {}

Local lRet			:= .T. 

Local oModel

nLenACBDes := TamSX3("ACB_DESCRI")[1]

//Pega arquivo
cGetFile := AllTrim( cGetFile ) 

//Separa nome do arquivo e extensão 
SplitPath( cGetFile, , , @cFile, @cExten )

cNameTerm := Upper(AllTrim(cFile+cExten))
cNameServ := cNameTerm

If(Len(cFile) > nLenACBDes)
	cFile := substr(cFile, 0, nLenACBDes)
EndIf

//Pega diretorio destino
If FindFunction( "MsMultDir" ) .And. MsMultDir()
	cDirDocs := MsRetPath( cNameServ )
Else
	cDirDocs := MsDocPath()
Endif

//renomeia existam caracteres especiais. Ex.: acentos 
cNameServ := Ft340RmvAc( cNameServ )

// Valida retorno função SplitPath
lRet := Len(cNameServ) < TamSX3("ACB_OBJETO")[1] - 36 

If lRet
	//Verifica se existe arquivo com o mesmo no diretório
	lRet 	:= !(File( cDirDocs + "\" + cNameServ ))
	
	//Recebe por POST as informações da cotação
	If	HttpSession->cCotacao == Nil
		HttpSession->cCotacao   := HttpPost->cCotacao
	EndIf
	
	If	HttpSession->cProposta == Nil
		HttpSession->cProposta   := HttpPost->cProposta
	EndIf
	If	HttpSession->dEXPIRYDATEFROM == Nil
		HttpSession->dEXPIRYDATEFROM := HttpPost->dEXPIRYDATEFROM
	EndIf
	
	If	HttpSession->dDEXPIRYDATETO == Nil
		HttpSession->dEXPIRYDATETO   := HttpPost->dEXPIRYATETO
	EndIf
	
	If	HttpSession->cCOMBOSIT == Nil
		HttpSession->cCOMBOSIT   := HttpPost->cCOMBOSIT
	EndIf
	
	If !(lRet)
		//Retorna motivo, caso falso
		Return PWSHtmlAlert( "",cNameServ + " não pode ser incluído, pois, já existe no diretório do Banco de Conhecimento. ", "Altere o nome do arquivo.", "W_PWSF064.APW?cCotacao=" + HttpSession->cCotacao + "&cProposta=" + HttpSession->cProposta + "&dEXPIRYDATEFROM=" + HttpPost->dEXPIRYDATEFROM + "&dEXPIRYDATETO=" + HttpPost->dEXPIRYDATETO + "&cCOMBOSIT=" + HttpPost->cCOMBOSIT, .F.)
		HttpSession->PWSF130APH[2] := "BC_EXIST"
		HttpSession->PWSF130APH[3] := cFile
		HttpSession->PWSF130APH[4] := cExten
	EndIf
EndIf

//Grava e Copia o arquivo para a pasta configurada
If lRet
	//instancia o modelo
	oModel := FWLoadModel('FATA340')      
	//Seta Inclusão no Modelo
	oModel:SetOperation(NOPER_INCLUSAO)
	//Ativa Modelo
	oModel:Activate()
	//Copia o arquivo
	__CopyFile( cGetFile, cDirDocs + "\" + cNameServ )
	//Atribui o valor no Banco de Conhecimento	
	M->ACB_OBJETO := cNameServ
	 
	oModel:SetValue("ACBMASTER","ACB_DESCRI",cFile)
	//Grava o Modelo
	lRet := FA340COMMI(oModel)	
EndIf

//Grava o Relacionamento Objeto x Entidade
If lRet
	//Posiciona a Entidade
	dbSelectArea( cEntidade )
	
	aEntidade := MsRelation()
	
	nScan := AScan( aEntidade, { |x| x[1] == cEntidade } )
	
	If Empty( nScan )
		//Localiza a chave unica pelo SX2                                        ³
		If !Empty( GetSx2Unico(cEntidade) )       
		   //Macro executa a chave unica                                            ³
			cUnico   := GetSx2Unico(cEntidade) 
			cCodEnt  := &cUnico 
		EndIf 					
		 	   
	Else 
		aChave   := aEntidade[ nScan, 2 ]
		cCodEnt  := MaBuildKey( cEntidade, aChave ) 
	
	EndIf

	//Inclui e grava os campos chave
	RecLock( "AC9", .T. ) 		
	AC9->AC9_FILIAL := xFilial( "AC9" )
	AC9->AC9_FILENT := xFilial( cEntidade )
	AC9->AC9_ENTIDA := cEntidade
	AC9->AC9_CODENT := cCodEnt
	AC9->AC9_CODOBJ := oModel:GetValue("ACBMASTER","ACB_CODOBJ")
	
	AC9->( MsUnlock() )
	
	//Devolve para a página com mensagem de sucesso!
	HttpSession->PWSF130APH[2] := "BC_OK"
	Return PWSHtmlAlert( "", "",cNameServ + " foi atualizado com SUCESSO no Banco de Conhecimento. ", "W_PWSF064.APW?cCotacao=" + HttpSession->cCotacao + "&cProposta=" + HttpSession->cProposta + "&dEXPIRYDATEFROM=" + HttpPost->dEXPIRYDATEFROM + "&dEXPIRYDATETO=" + HttpPost->dEXPIRYDATETO + "&cCOMBOSIT=" + HttpPost->cCOMBOSIT, .F.)
		
EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc}Pwsf130Sav
Salva o arquivo do banco de conhecimento da cotação para o Terminal

@author José Eulálio
@since 05/05/2015
@version P12.1.5
/*/
//-------------------------------------------------------------------
Web Function Pwsf130Sav()
Local cDirDocs	:= ""
Local cDirTerm	:= ""
Local cFile		:= ""
Local cExten	:= ""     
Local cNameTerm	:= ""
Local cNameServ	:= ""
Local cEmpPF	:= ""
Local cHtml		:= ""
Local cPathJob 	:= ""
Local cPathSrv 	:= ""
Local cDownload := ""
Local nRet		:= 0
Local nI		:= 0
Local aJob

cEmpPF		:= HTTPSESSION->PWSF131EMPFIL[1]
HttpSession->PWSF131DWL := ""
HttpSession->PWSF131POS	:= ""

If	!Empty( HttpPost->cObjeto )
	HttpGet->cObjeto := HttpPost->cObjeto
	HttpGet->pos 		:= HttpPost->pos
EndIf

cNameTerm := Upper(AllTrim(HttpGet->cObjeto))
cNameServ := ALLTRIM(cNameTerm) 


//Pega diretorio destino
If MsMultDir()
	cDirDocs := MsRetPath( cNameServ )
Else
	cDirDocs := MsDocPath()
Endif

//Verifica se existe arquivo no diretório
lRet 	:= File( cDirDocs + "\" + cNameServ )

aJob := JobInfo()
cPathJob := ""
For nI := 1 to Len(aJob) 
	cPathJob := GetPvProfString( aJob[nI][1], "INSTANCENAME", "", GetADV97() )
	If UPPER(cPathJob) == "PP"
		cPathJob := GetPvProfString( aJob[nI][1], "Path", "", GetADV97() )		
		Exit
	EndIf
Next nI


//Recupera a pasta do Job do Portal 
cPathSrv	:= GetSrvProfString("ROOTPATH","")
cPathJob	:= StrTran(upper(cPathJob), upper(cPathSrv),"")
cDirTerm 	:= cPathJob + '\CO' + cEmpPF
cDownload	:= 'CO' + cEmpPF + '/' + ALLTRIM(cNameServ)



//Verifica se existe e cria, caso necessário, diretórios web para cópia do arquivo
If !(ExistDir(cDirTerm))
	nRet := MakeDir(cDirTerm)
EndIf

//Copia arquivo para o diretório Web
If nRet <> 0
	lRet := .F.
Else
	lRet := __CopyFile( cDirDocs + "\" + cNameServ , cDirTerm + "\" + cNameTerm )
	HttpSession->PWSF131DWL	:= cNameTerm
	HttpSession->PWSF131POS	:= HttpGet->pos	
EndIf

If lRet	
	//Return PWSHtmlAlert( "", "","Arquivo " + cNameServ + " encontrado. ", "W_PWSF131.APW?dlok=" + HttpSession->PWSF131DWL , .F.)
	cHtml += "<script>window.open('"+ cDownload +"', '_blank')</script>"
	ExecInPage("PWSF131")
Else
	Return PWSHtmlAlert( "", "","Não foi possível salvar o arquivo. ", "W_PWSF131.APW" , .F.)
EndIf

Return cHtml
