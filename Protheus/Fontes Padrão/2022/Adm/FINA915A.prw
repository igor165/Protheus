#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'FWMVCDEF.CH'
#Include "ApWizard.ch"
#include "fileio.ch"
#include "FINA915A.ch"

Function FINA915A()
	WizImport()
Return Nil


//-------------------------------------------------------------------
/*/{Protheus.doc} WizImport
Fun��o que monta as etapas do Wizard de Configura��es  

@author Totvs
@since 13/01/2015	
@version 11.80
/*/

//-------------------------------------------------------------------

Static Function WizImport()
	Local oWizard
	Local cArquivo := ""
	Local cPsw := ""
	
	//Private lEnd 	:= .T.
	
	//Painel 1 - Tela inicial do Wizard 
	oWizard := APWizard():New( OemToAnsi(STR0001), "", OemToAnsi(STR0002),OemToAnsi(STR0003),{||.T.}, {||.T.}, .F. )
	
	//Painel 2 - Importa��o de arquivo
	oWizard:NewPanel( OemToAnsi(STR0004), OemToAnsi(STR0005),{||.T.},{||.T.}, {|| .T. }, .F., {|| MontaTela( oWizard, @cArquivo) } )
	
	oWizard:NewPanel(OemToAnsi(STR0006),OemToAnsi(STR0007),{||.T.},{||.T.},{||F915Amsg(cArquivo)},.T.,{||.T.})
	
	oWizard:Activate( .T., {||.T.}, {||.T.}, {||.T.} )
	
Return Nil

//--------------------------------------------------------------------
/*/{Protheus.doc} MontaTela
Fun��o que monta, no Wizard, a tela com o campo de sele��o do arquivo 
de importa��o 

@param oWizard, Objeto da classe APWizard
@param cArquivo, Caminho do arquivo de importa��o (por refer�ncia)


@author Totvs
@since 13/01/2015
@version 11.80
/*/
//--------------------------------------------------------------------
Static Function MontaTela(oWizard, cArquivo)
	Local oPanel := oWizard:oMPanel[oWizard:nPanel]   
	Local oGet1
	Local cArqAnt := ""
	
	Default cArquivo := ""
	
	//Caminho do arquivo de certificado
	TSay():New( 010, 018, {|| OemToAnsi(STR0008) }, oPanel, , , , , , .T. )
	oGet1 := TGet():New( 008, 095, {|u| Iif( PCount() > 0, cArquivo := u, cArquivo + Space( 250 - Len( cArquivo ) ) ) }, oPanel, 150,,,,,,,,,.T.,,,,,,,,.F.,,"cArquivo" )
	oGet1:bHelp := {|| Help( , , OemToAnsi(STR0008), , OemToAnsi(STR0009), 1, 0 ) }
	SButton():New( 008, 250, 14, {|| cArqAnt := cArquivo, cArquivo := AllTrim( cGetFile( OemToAnsi(STR0010), OemToAnsi(STR0011), 0, "", .F.,, .T. ) ) , Iif( Empty( cArquivo ), cArquivo := cArqAnt, ) }, oPanel , )
    
Return Nil


/*/{Protheus.doc} ModelDef
Modelo de neg�cio do processamento do arquivo
@author Totvs
@since  13/01/2015
@version 11.80
/*/


Static Function ModelDef()
// Cria a estrutura a ser usada no Modelo de Dados
Local oStruFJP := FWFormStruct( 1, 'FJP', /*bAvalCampo*/,/*lViewUsado*/ )
// Cria o objeto do Modelo de Dados
Local oModel 	 := MPFormModel():New('FINA915')//, /*bPreValidacao*/, /*bPosValidacao*/, /*{|oModel|F915GRV(oModel)}*/, /*bCancel*/ )
Local oCab		 := FWFormModelStruct():New()

//Criado falso field, para alimentar a FJ0 de uma unica vez pelo Detail
oCab:AddTable('MASTER',,'MASTER')
oCab:AddField("Id","","FJP_CAMPO","C",1,0,/*bValid*/,/*When*/,/*aValues*/,.F.,{||'"1"'},/*Key*/,.F.,.T.,)

// Adiciona ao modelo uma estrutura de formul�rio de edi��o por campo
oModel:AddFields('FJPMASTER', /*cOwner*/, oCab , , ,{|o|{}} )
oModel:AddGrid('FJPDETAIL','FJPMASTER',oStruFJP)
// Adiciona a descricao do Modelo de Dados
oModel:GetModel('FJPMASTER' ):SetPrimaryKey( {} )
oModel:GetModel('FJPMASTER' ):SetOnlyQuery(.T.)
oModel:SetDescription( OemToAnsi(STR0012) )
// Adiciona a descricao do Componente do Modelo de Dados
oModel:GetModel( 'FJPMASTER' ):SetDescription( OemToAnsi(STR0012) )
oModel:GetModel('FJPDETAIL'):SetDescription(OemToAnsi(STR0012))

oModel:GetModel("FJPDETAIL"):SetMaxLine( 2000 ) 
 

Return oModel


//--------------------------------------------------------------------
/*/{Protheus.doc} A915aVldArq
Fun��o que valida o arquivo de importa��o e aciona a grava��o da tabela FJP

@param cArquivo, arquivo de importa��o informado pelo usu�rio

@author Totvs


@since 14/01/2015
@version 11.80
/*/
//--------------------------------------------------------------------
Static Function A915aVldArq(cCamArq/*,lEnd*/)

Local nHdlFile 	:= 0
Local nFator 		:= 1
Local nRecCount	:= 0
Local nTam			:= 0
Local cLinha		:= ""		//variavel de leitura da linha
Local nValor		:= 0
Local oModel  	:= FWLoadModel("FINA915A")
Local oSubFJP
Local lRet			:= .T.
Local nReg			:= 2000
Local nx			:= 1
Local nCont		:= 0
Local cChaveArq	:= ""
Local aLog			:= {}	

	dbSelectArea("FJP")
	dbSetOrder(3)	//FJP_FILIAL+FJP_IDARQU
	
	nHdlFile := FT_FUse(cCamArq)
	nRecCount := FT_FLASTREC()
	fClose(nHdlFile)
	FT_FUSE()


	nHdlFile := fOpen(cCamArq)
	//se arquivo tiver mais de 2 mil registros realiza o commit e atualiza��o de tela a cada 1000               
	If nRecCount > 2000
		nFator := ROUND(nRecCount/nReg, 0)
	EndIf

	nTam := 1000
	
	BEGIN TRANSACTION

	If !(nHdlFile == -1) 

		//inicia transacao  -- somente na leitura do arquivo texto eh permitido abortar
		//                     transacao existe pq em algum momento ele deleta registro na tabela FIF
	
			For nx:= 1 to nFator
				nCont := 1
				
				oModel:SetOperation( MODEL_OPERATION_INSERT ) //Inclusao
				oModel:Activate()
				oSubFJP  := oModel:GetModel("FJPDETAIL")
	
				oModel:SetValue('FJPMASTER','FJP_CAMPO', '1')
				
				While  nCont <= nReg
				
					//Proxima linha
					If !(fReadLn(nHdlFile,@cLinha,nTam))
						Exit 
					Endif
					
					If Empty(cLinha)
						Loop
					EndIf
		
					//���������������������������������������������������Ŀ
					//�Retira as aspas duplas e troca por espaco em branco�
					//�senao a funcao strtokarr nao traz a coluna         �
					//�����������������������������������������������������
					cLinha	:= StrTran(cLinha,'""'," ")
		
					//Retira os caracteres especiais, no caso o " que separa os registros
					cLinha	:= StrTran(cLinha,'"',"")
		
					//Transforma a linha em um array com todos os registros
					aLinha	:= StrToKArr(cLinha,";")
					
					//Prote��o para leitura de arquivos fora de padr�o.
					If Len(aLinha) < 4
						Loop
					EndIf
					
					
					cChaveArq:= aLinha[2]+aLinha[3]+aLinha[4]+aLinha[5]+aLinha[6]+aLinha[9]
					
					If !(FJP->( MsSeek( xFilial("FJP") +cChaveArq ) ))
						If aLinha[9] == "LP"
					
							nValor := Round(Val(aLinha[10]),2 )+Round(Val(aLinha[11]),2 )+Round(Val(aLinha[12]),2 )+Round(Val(aLinha[13]),2 )
							
							If !oSubFJP:IsEmpty()
								//Inclui a quantidade de linhas necess�rias
								oSubFJP:AddLine()		
								//Vai para linha criada
								oSubFJP:GoLine( oSubFJP:Length() )	
							Endif
							
							
							oSubFJP:SetValue( "FJP_IDPROC"   , FWUUIDV4()		 	)
							oSubFJP:SetValue( "FJP_CONTR" 	  , aLinha[4]		 	)
							oSubFJP:SetValue( "FJP_DTIMP"     , dDataBase 		)
							oSubFJP:SetValue( "FJP_DTPARC"    , CTOD(aLinha[8])	)
							oSubFJP:SetValue( "FJP_VALOR"     , nValor			)
							oSubFJP:SetValue( "FJP_SITUAC"    , "1"				)
							oSubFJP:SetValue( "FJP_IDARQU"    , cChaveArq 		)
						
							nCont ++
								
						Endif	
					Else
						aAdd(aLog,{OemToAnsi(STR0013),cLinha})	
					Endif
					
				Enddo
				
				If !oSubFJP:IsEmpty()
					If oModel:VldData()
					    oModel:CommitData()
				  	Else
						lRet := .F.
					    cLog := cValToChar(oModel:GetErrorMessage()[4]) + ' - '
					    cLog += cValToChar(oModel:GetErrorMessage()[5]) + ' - '
					    cLog += cValToChar(oModel:GetErrorMessage()[6])        	
					    
					    Help( ,,"F915VLDA1",,cLog, 1, 0 )	             
					Endif			
					
				Endif
				oModel:DeActivate()
			Next
	Endif
	
	
	If Len(aLog)>0 .AND. Aviso(OemToAnsi(STR0014),OemToAnsi(STR0015),{OemToAnsi(STR0016),OemToAnsi(STR0017)}) == 1
		F915GrvLog(aLog)
	Endif	
	
	END TRANSACTION	//termino transacao
	MsUnlockAll()

return lRet


/*/{Protheus.doc} F915Amsg
Fun��o que abre uma msgRun para grava��o dos registros no final do 
Wizard

@author Totvs
@since 16/01/2015	
@version 11.80
/*/
//--------------------------------------------------------------------


Static Function F915Amsg(cArquivo)
	//"Gravando Par�metros..."
	MsgRun (OemToAnsi(STR0018),"A915aVldArq",{||A915aVldArq(cArquivo)})
Return .T. 



/*/{Protheus.doc} F915GrvLog
Fun��o efetua a grava��o do log

@author Totvs
@since 16/01/2015	
@version 11.80
/*/
//--------------------------------------------------------------------


Static Function F915GrvLog(aLog)

	Local cType := OemToAnsi(STR0019)		//"Arquivos LOG"	### "(*.log) |*.log|"
	Local cDir	:= cGetFile(cType ,OemToAnsi(STR0020),0,,.F.,GETF_LOCALHARD + GETF_NETWORKDRIVE + GETF_RETDIRECTORY)			//"Selecione o diretorio para grava��o do LOG"
	Local nHdl	:= 0                           //Handle do arquivo
	Local cDados:= ""                          //Descri��o da Linha
	Local nI	:= 0                           //Variavel contadora de log
	Local cLin	:= ""                          //Variavel da linha do log
	Local cEOL	:= CHR(13)+CHR(10)            //Final de Linha
  	Local nFator := If(Len(alog) > 2000, 1000, 1)

	//Incluo o nome do arquivo no caminho ja selecionado pelo usuario
	cDir := Upper(Alltrim(cDir)) + "LOG_FINA915_" + dTos(dDataBase) + StrTran(Time(),":","") + ".LOG"

	If (nHdl := FCreate(cDir)) == -1
	    MsgInfo(OemToAnsi(STR0021)+ cDir + OemToAnsi(STR0022))			//"O arquivo de nome "	### " nao pode ser executado! Verifique os parametros."
	    Return
	EndIf

	cDados	:= OemToAnsi(STR0023)								//"Linha da Ocorrencia;Tipo da Ocorrencia;Descricao da Ocorrencia"
	cLin	:= Space(Len(cDados)) + cEOL
	cLin	:= Stuff(cLin,01,Len(cDados),cDados)

	If FWrite(nHdl,cLin,Len(cLin)) != Len(cLin)
		If Aviso(OemToAnsi(STR0014),OemToAnsi(STR0015),{OemToAnsi(STR0016),OemToAnsi(STR0017)}) == 2		//"Atencao"	### "Ocorreu um erro na gravacao do arquivo. Continua?"	### "Sim"	### "N�o"
			FClose(nHdl)
			Return
		EndIf
	EndIf

	ProcRegua(Len(aLog)/nFator)                      

	For nI := 1 to Len(aLog)

		If nI%nFator == 0
			IncProc(OemToAnsi(STR0024) + "(" + AllTrim(Str(nI)) + "/" + AllTrim(Str(Len(aLog))) + ")")			//"Gravando os Log's..."
        EndIf
		cDados	:= aLog[nI][1] + ';' + aLog[nI][2]
		cLin	:= Space( Len(cDados) ) + cEOL
		cLin	:= Stuff(cLin,01,Len(cDados),cDados)

		If FWrite(nHdl,cLin,Len(cLin)) != Len(cLin)
			If Aviso(OemToAnsi(STR0014),OemToAnsi(STR0015),{OemToAnsi(STR0016),OemToAnsi(STR0017)}) == 2		//"Atencao"	### "Ocorreu um erro na gravacao do arquivo. Continua?"	### "Sim"	### "N�o"
				FClose(nHdl)
				Return
			EndIf
		EndIf
	Next nI

	FClose(nHdl)


Return