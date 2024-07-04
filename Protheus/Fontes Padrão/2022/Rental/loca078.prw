#include 'protheus.ch'
#include 'parmtype.ch'
#Include "TOTVS.ch"
#Include "RestFUL.ch"
#Include "TBIConn.ch"
#Include "TOPConn.ch"
#INCLUDE "LOCA078.CH" 

//-------------------------------------------------------------------
/*/{Protheus.doc} fdic_migr
@description	Migração de dados 
@author			José Eulálio
@since     		16/03/2020
@History		03/06/2021, Frank Zwarg Fuga, Produtização
/*/
//-------------------------------------------------------------------                              
Main Function LOCA078()

Local cTitulo	:= STR0001 //"Facilitador de Migração de Dados"
Local cMsg1     := STR0002 //"Esta rotina foi desenvolvida para facilitar a geração e leitura de arquivos do tipo CSV (Comma-Separated Values). O que deseja realizar?"
Local cMsg2     := STR0003 //"preparando ambiente para "
Local cBtn1		:= STR0004 //"Gerar CSV"
Local cBtn3		:= STR0005 //"Atualizar base"
Local cBtn2		:= STR0006 //"Simular Atual."
Local nRetFunc	:= 0

PRIVATE oMainWnd 

Set Dele On	

nRetFunc := AVISO(cTitulo, cMsg1, { cBtn3,cBtn2,cBtn1,STR0008}, 2) //Fechar

If nRetFunc <> 4
	
	If nRetFunc == 1
		cMsg2	:= STR0007 //"preparando ambiente para atualização da base de dados"
	ElseIf nRetFunc == 3
		cMsg2	:= STR0009 //"gerar arquvivo formato CSV"
	ElseIf nRetFunc == 2
		cMsg2	:= STR0010 //"preparando ambiente para simulação de importação"
	EndIf

	DEFINE WINDOW oMainWnd FROM 0,0 TO 01,30 TITLE cTitulo //"Facilitador de Migração de Dados"
	
	ACTIVATE WINDOW oMainWnd ;                        //"Processando" "Aguarde, atualizando base de dados", "Processo finalizado", "Processo finalizado"
		ON INIT If( .T. ,(Processa({|| LOCA07801(nRetFunc)},STR0011,STR0012 + cMsg2,.F.) , FinalMsg(STR0013)),FinalMsg(STR0013))
EndIf	

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} FinalMsg
@description	Mostra mensagem e finaliza processo
@author			José Eulálio
@since     		16/03/2020
/*/
//-------------------------------------------------------------------  
Static Function FinalMsg(cMensagem)
	MsgStop(cMensagem)
	oMainWnd:End()	
Return

//-------------------------------------------------------------------
/*/{Protheus.doc} LOCA07801
@description	Executa a atualizacao dos dados
@author			José Eulálio
@since     		16/03/2020
/*/
//-------------------------------------------------------------------  
Static Function LOCA07801(nRetFunc)

Local lOpen     	:= .F.
Local lExclusivo	:= .F.								//Indica se conseguiu fazer a abertura
Local aRecnoSM0 	:= {}     								//Array com os Recnos da tab. de empresas
local nI  

/*If nRetFunc == 1
	lExclusivo := .T.
EndIf*/

//IncProc(STR0008) //"Verificando integridade dos dicionáios...."
If ( lOpen := MyOpenSm0Ex(lExclusivo) )                                                     
             
	dbSelectArea("SM0")
	dbGotop()

	While !Eof() 
  		If Ascan(aRecnoSM0,{ |x| x[2] == M0_CODIGO}) == 0 //--So adiciona no aRecnoSM0 se a empresa for diferente
			Aadd(aRecnoSM0,{Recno(),M0_CODIGO})
		EndIf			
		dbSkip()
	EndDo	
                
	ProcRegua(Len(aRecnoSM0))
	For nI := 1 To (Len(aRecnoSM0) - IIF(aScan(aRecnoSM0, {|x| x[2] == "99"}) == 0 ,0,1)) //só tirei pq estava vindo a 99
		SM0->(dbGoto(aRecnoSM0[nI,1]))
		RpcSetType(2) 
		RpcSetEnv(SM0->M0_CODIGO, SM0->M0_CODFIL)
		
		If nRetFunc == 1 .Or. nRetFunc == 2
			LOCA07802(nRetFunc)
		ElseIf nRetFunc == 3
			LOCA07803()
		EndIf
				
		RpcClearEnv()

	Next nI 

 EndIf 	

Return .T.                       
                               

//-------------------------------------------------------------------
/*/{Protheus.doc} MyOpenSM0Ex
@description	Abre empresa
@author			José Eulálio
@since     		16/03/2020
/*/
//-------------------------------------------------------------------  
Static Function MyOpenSM0Ex(lExclusivo)

Local cUsrAux	:= ""
Local cPswAux	:= ""
Local cInfEmp	:= ""
Local cInfFil	:= ""
Local lOpen		:= .F.		//Indica se conseguiu fazer a abertura
Local nLoop 	:= 0 		//Usada em lacos For...Next

Default	lExclusivo	:= .F.

If lExclusivo
	For nLoop := 1 To 20
		dbUseArea( .T.,, "SIGAMAT.EMP", "SM0", .F., .F. ) //Verificar 
		If !Empty( Select( "SM0" ) ) 
			lOpen := .T. 
			dbSetIndex("SIGAMAT.IND") 
			Exit	
		EndIf
		Sleep( 500 )                                                                                    
	Next nLoop
Else
	//Verificando se o login deu certo
	If LOCA07804(@cUsrAux, @cPswAux, @cInfEmp, @cInfFil)
		If !Empty(cInfEmp) .And. !Empty(cInfFil)
			//Limpando o ambiente atual e criando novamente
			RPCClearEnv()
			RPCSetType(3) 
			RPCSetEnv(cInfEmp, cInfFil, cUsrAux, cPswAux, "SIGAFAT")
			If !Empty( Select( "SM0" ) ) 
				lOpen := .T. 
			EndIf
		EndIf
	EndIf
EndIf


If !lOpen	
	MsgStop(STR0019,STR0017)  //"Nao foi possivel a abertura da tabela de empresas de forma exclusiva !" "Atencao !"
EndIf                                 

Return( lOpen ) 

//-------------------------------------------------------------------
/*/{Protheus.doc} LOCA07803
@description	Cria arquivos .csv
@author			José Eulálio
@since     		16/03/2020
/*/
//-------------------------------------------------------------------  
Static Function LOCA07803()

Local cRange	:= "PA"
Local cAliasAux	:= ""
Local cReturn	:= ""
Local cLocal	:= ""
Local cListEnt	:= ""
Local cDesX3	:= ""
Local cEntidades:= Space(50)
Local nHandle	:= 0
Local nHandX3	:= 0
Local nX		:= 0
Local aPergs	:= {}
Local aRet		:= {}
Local aEnts		:= {}
Local _cInst   

_cInst := "SX2->( dbSetOrder( 1 ) )"
&(_cInst) //SX2->( dbSetOrder( 1 ) ) 
_cInst := "SX2->( dbSeek( 'FP0' ) )"
_cInst1:= "SX2->( dbSeek( 'ZA0' ) )"
If &(_cInst) //SX2->( dbSeek( "FP0" ) )  
	cEntidades:= "FP0;FP1;FPA" + Space(39)
	lMod94	:= .T.
Else
	Return .F.
EndIf

aAdd( aPergs ,{1 ,STR0015 ,cEntidades ,"@!"  , "","", ".T." ,100 , .T.}) //"Entidades(;)" Tipo caractere
aAdd( aPergs ,{1 ,STR0016 ,Space(50) ,"@!"  , "","", ".T." ,100 , .T.}) //"Local" Tipo caractere

					//"Informe a Entidade e Local de gravação do CSV"
If ParamBox(aPergs ,STR0014,@aRet,,,,,,,,.F.)
	If ExistDir(aRet[2])
		cLocal:= AllTrim(aRet[2])
		aEnts := StrToKarr(AllTrim(aRet[1]),";")
	Else
		Help(Nil,	Nil,"RENTAL: "+alltrim(upper(Procname())),;
			Nil,STR0017,1,0,Nil,Nil,Nil,Nil,Nil, {STR0018}) //"Atenção!" - "Não existe o caminho indicado"
	EndIf
	For nX := 1 To Len(aEnts)
		If !Empty(aEnts[nX])
			cRange	:= aEnts[nX]
			nHandle	:= 0
			(LOCXCONV(1))->( DBSETORDER(1) )
			If (LOCXCONV(1))->( DBSEEK( cRange, .T. ) ) //SX3->(dbSeek(cRange))
				While ! (LOCXCONV(1))->( EOF() ) .AND. GetSx3Cache(&(LOCXCONV(2)),"X3_ARQUIVO") == cRange //!SX3->(Eof()) .and. cRange $ SX3->X3_ARQUIVO
					If cAliasAux <> GetSx3Cache(&(LOCXCONV(2)),"X3_ARQUIVO") //SX3->X3_ARQUIVO
						If nHandle > 0
							FWrite(nHandle, cReturn + CRLF)
							FClose(nHandle)
						EndIf
						cReturn		:= ""
						cAliasAux	:= GetSx3Cache(&(LOCXCONV(2)),"X3_ARQUIVO") //SX3->X3_ARQUIVO
						_cInst := "SX2->( dbSetOrder( 1 ) )"
						&(_cInst) //SX2->( dbSetOrder( 1 ) ) 
						_cInst := "SX2->( dbSeek( cAliasAux ) )"
						If &(_cInst) //SX2->( dbSeek( cAliasAux ) )  
							_cInst := "SX2->X2_CHAVE + ' - ' + SX2->X2_NOME + CRLF"
							cListEnt   += &(_cInst) //SX2->X2_CHAVE + " - " + SX2->X2_NOME + CRLF
						EndIf 
						If nHandX3 > 0
							FClose(nHandX3)
						EndIf
						nHandle := FCREATE(cLocal + "\" + Upper(cAliasAux )+ "imp.csv")
						nHandX3 := FCREATE(cLocal + "\" + Upper(cAliasAux )+ "-sx3.csv")
						FWrite(nHandX3, "X3_ORDEM;X3_CAMPO;X3_DESCRIC;X3_OBRIGAT;X3_TAMANHO;X3_DECIMAL;X3_TITULO;X3_TIPO;X3_PICTURE;X3_F3;X3_CBOX" + CRLF)
						
					EndIf
					
					If GetSx3Cache(&(LOCXCONV(2)),"X3_CONTEXT") <> "V"
						cReturn += GetSx3Cache(&(LOCXCONV(2)),"X3_CAMPO") + "," + GetSx3Cache(&(LOCXCONV(2)),"X3_TIPO") + "," + cValToChar(GetSx3Cache(&(LOCXCONV(2)),"X3_TAMANHO")) + ";"
						cDesX3	:= GetSx3Cache(&(LOCXCONV(2)),"X3_ORDEM") + ";" + GetSx3Cache(&(LOCXCONV(2)),"X3_CAMPO") + ";" + GetSx3Cache(&(LOCXCONV(2)),"X3_DESCRIC") + ";" + GetSx3Cache(&(LOCXCONV(2)),"X3_OBRIGAT") + ";" + cValToChar(GetSx3Cache(&(LOCXCONV(2)),"X3_TAMANHO")) + ";" + cValToChar(GetSx3Cache(&(LOCXCONV(2)),"X3_DECIMAL")) + ";" + GetSx3Cache(&(LOCXCONV(2)),"X3_TITULO") + ";" + GetSx3Cache(&(LOCXCONV(2)),"X3_TIPO") + ";" + GetSx3Cache(&(LOCXCONV(2)),"X3_PICTURE") + ";" +GetSx3Cache(&(LOCXCONV(2)),"X3_F3") + ";" + StrTran( GetSx3Cache(&(LOCXCONV(2)),"X3_CBOX"), ";", "," ) + CRLF
						FWrite(nHandX3, cDesX3)
					EndIF
					SX3->(dbSkip())
				EndDo
			EndIf
			If nHandle > 0
				FWrite(nHandle, cReturn + CRLF)
				FClose(nHandle)
			EndIf
			If nHandX3 > 0
				FClose(nHandX3)
			EndIf
		EndIf
	Next nX
	If !Empty(cLocal) 
		nHandle := FCREATE(cLocal + "\ListaCsv.txt")
		FWrite(nHandle, STR0030 + CRLF+ CRLF) //"lista de entidades e nomes"
		FWrite(nHandle, cListEnt + CRLF)
		FClose(nHandle)
	EndIf
EndIf

Return cReturn

//-------------------------------------------------------------------
/*/{Protheus.doc} LOCA07802
@description	Cria arquivos .csv
@author			José Eulálio
@since     		16/03/2020
/*/
//-------------------------------------------------------------------  
Static Function LOCA07802(nRetFunc)
Local cLocal	:= ""
local cDirDest	:= ""
Local cHora		:= ""
Local aHora		:= {}
//Local aPergs	:= {}
Local aFiles 	:= {} // O array receberá os nomes dos arquivos e do diretório
Local aSizes 	:= {} // O array receberá os tamanhos dos arquivos e do diretorio
//Local aRet		:= {}
Local nCount	:= 0
Local nX		:= 0
Local nHandLog	:= 0

Default nRetFunc := 1

cDirDest := cGetFile( '.' , STR0031, 1, 'C:\ITUP\MIGRA\CSV', .F., nOR( GETF_LOCALHARD, GETF_LOCALFLOPPY, GETF_RETDIRECTORY ),.T., .T. ) //'Informe o Local dos arquivos CSV'

If ExistDir(cDirDest)
	//cLocal:= AllTrim(aRet[1])
	cLocal:= AllTrim(cDirDest)
	
	ADir(cLocal + "\*.csv", aFiles, aSizes)
		// Exibe dados dos arquivos
	nCount := Len( aFiles )
	Begin Transaction
	
	aHora	:= StrToKarr(Time(),":")
	For nX := 1 to Len(aHora)
		cHora += aHora[nX]
	Next nX

	nHandLog := FCREATE(cLocal + "\" + DtoS(dDataBase) + cHora + "-logmig.txt")
	FWrite(nHandLog, STR0032 + DtoC(dDataBase) + " - " + Time() + CRLF + CRLF) //"LOG DE ATUALIZAÇÃO DE MIGRAÇÃO DE DADOS - "

	If nCount > 0
		
		// Se existir o PE abaixo realiza a gravação customizada
		If ExistBlock("ITUPMIGG")
			ExecBlock("ITUPMIGG",,,{cLocal,aFiles,nRetFunc,nHandLog})
		Else
			For nX := 1 to nCount
				CsvProcess(cLocal + "\" + aFiles[nX],aFiles[nX],nHandLog)
			Next nX
		EndIf
	Else
		DisarmTransaction()
		MsgStop(STR0033, STR0017) //"Não existem arquivos com extenção .csv no diretório indicado"
		FWrite(nHandLog, STR0033 + CRLF) //"Não existem arquivos com extenção .csv no diretório indicado"
	EndIf

	FWrite(nHandLog, Replicate("-",90) + CRLF)
	FWrite(nHandLog, CRLF + STR0034 + Time() + CRLF) //"LOG DE ATUALIZAÇÃO DE MIGRAÇÃO DE DADOS FINALIZADO! - "
	FClose(nHandLog)
				//"Confira o arquivo "                                                 
	If MsgYesNo( STR0035 + cLocal + "\" + DtoS(dDataBase) + cHora + "-logmig.txt" + CRLF + STR0036 , STR0037 ) //"Deseja abrí-lo agora?" - "Finalizado !"
		ShellExecute("open", DtoS(dDataBase) + cHora + "-logmig.txt", "", cLocal, 1)
	EndIf		
	
	End Transaction
	
Else
	//MsgStop("Não existe o caminho indicado", "Atencao !")
	MsgStop(STR0038,STR0017) //
EndIf

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} CsvProcess
@description	Lê arquivo .csv e processa inclusão 
@author			José Eulálio
@since     		17/03/2020
/*/
//-------------------------------------------------------------------
Static Function CsvProcess(_cFile, cArquivo, nHandLog)
Local _nHandle 	:= 0
Local _nLast	:= 0
Local _nCount	:= 1
Local nX		:= 0
Local nPosCsv	:= 0
Local cCabUlt	:= ''
Local cAliasAux	:= ''
Local cAliasCsv	:= ''
Local cCpoCsv	:= ''
Local _cLine	:= ''
Local cKeyCsv	:= ""
Local cObrigat	:= ""
Local aKeyCsv	:= {}
Local _aDados  	:= {}
Local _aArea	:= GetArea()
Local aCabCsv	:= {}
Local aObrigat	:= {}
Local lContinua	:= .T.
Local lCabQuebra:= .F.
Local xValue

nHandle := FT_FUse( _cFile )
FWrite(nHandLog, Replicate("-",90) + CRLF)
FWrite(nHandLog, "Arquivo: " + _cFile + CRLF)
FWrite(nHandLog, "Iniciado: " + Time() + CRLF)
// Se houver erro de abertura abandona processamento
If _nHandle = -1
	
	DisarmTransaction()
	
	FWrite(nHandLog, STR0039 + CRLF) //"Arquivo não processado!"
	MsgStop(STR0039,STR0017)

	lContinua	:= .F.

EndIf

If lContinua
	// Posiciona na primeira linha
	FT_FGoTop()
	
	//Retorna o número de linhas do arquivo
	_nLast := FT_FLastRec()
	
	ProcRegua( _nLast )
	IncProc(STR0040 + cArquivo + "...") //"Atualizando arquivo "
		
	Do While !FT_FEOF() .And. _nCount <= _nLast
	//"Atualizando arquivo " ---- "Processando registro: "
		IncProc(STR0040 + cArquivo + "..." + CRLF+ STR0041 + cValToChar( _nCount ) + " de " + cValToChar( _nLast ))
			
		_cLine  := FT_FReadLn()
	
		_aDados := Str2Arr( _cLine , ";" )
		
		lCabQuebra	:= (!Empty(cAliasAux) .And. cAliasAux $ _cLine)
		
		If (_nCount == 1 .Or. lCabQuebra) .And. Len(_aDados) > 0
			
			//Verifica se tem o cabeçalho
			If "_FILIAL" $ _aDados[1] .Or. "_FILIAL" $ _aDados[2] .Or. lCabQuebra
				If _nCount == 1
					cAliasAux	:= SubStr(_aDados[1],1,AT( "_", _aDados[1] )-1)
					cAliasCsv	:= LimpaAspa(IIF(Len(cAliasAux) == 2, "S" + cAliasAux, cAliasAux))
				EndIf
				For nX := 1 To Len(_aDados)
					If "," $ _aDados[nX]
						cCpoCsv	:= AllTrim(SubStr(_aDados[nX],1,AT( ",", _aDados[nX] )-1))
					Else
						cCpoCsv	:= AllTrim(_aDados[nX])
					EndIf
					//Manobra não convencional para contornar o fato da função FT_FReadLn quebrar linhas maiores que 1Mb
					If nX == 1 .And. !Empty(cCabUlt)
						(LOCXCONV(1))->( DBSETORDER(2) )
						If (LOCXCONV(1))->( DBSEEK( Padr(cCabUlt,10), .T. ) ) 
							cCabUlt := ""
						Else
							cCpoCsv := cCabUlt+cCpoCsv
							ASize(aCabCsv,Len(aCabCsv)-1)
						EndIf
					EndIf
					//SubStr(_aDados[nX],AT( ",", _aDados[nX] )+1,1)
					If !Empty(cCpoCsv)
						cCpoCsv := LimpaAspa(cCpoCsv)
						Aadd(aCabCsv,{cCpoCsv,Posicione(LOCXCONV(1),2,cCpoCsv,LOCXCONV(5))})
					EndIf
				Next nX
				cCabUlt := aCabCsv[Len(aCabCsv)][1]
				_nCount++
				FT_FSKIP()
			Else
				DisarmTransaction()
				FT_FUSE()
				FWrite(nHandLog, STR0042 + cArquivo + STR0043 + CRLF) // "O arquivo " --- "não possui um cabeçalho válido. "
				MsgStop(STR0042 + cArquivo + STR0043,STR0017)
			EndIf 
			
		Else
			If ConfereCab(aCabCsv,nHandLog)
				If Len(cAliasCsv) == 2
					cAliasCsv	:= LimpaAspa(IIF(Len(cAliasCsv) == 2, "S" + cAliasCsv, cAliasCsv))
				EndIf
				If _nCount > 1 .And. !EMPTY(_cLine) .And. !Empty(ArrToStr(_aDados))
					cChavCsv	:= ""
					(cAliasCsv)->(DbSetOrder(1))
					cKeyCsv	:= (cAliasCsv)->(IndexKey())
					(aKeyCsv) := StrToKarr(cKeyCsv,"+")
					For nX := 1 To Len(aKeyCsv)
						//limpa Dtos quando tem data na chave
						If "DTOS(" $ aKeyCsv[nX]
							aKeyCsv[nX]	:= StrTran(StrTran(aKeyCsv[nX],")",""),"DTOS(","")
						EndIf
						//limpa STR quando tem numerico na chave
						If "STR(" $ aKeyCsv[nX]
							aKeyCsv[nX]	:= StrTran(SubStr(aKeyCsv[nX],1,at(",",aKeyCsv[nX])-1),"STR(","")
						EndIf
						//posiciona no campo
						nPosCsv	:= v
						xValue	:= LimpaAspa(_aDados[nPosCsv])
						//Se não informou filial, usa de acordo dicionário
						If "_FILIAL" $ aKeyCsv[nX] .And. Empty(xValue)
							xValue	:= xFilial(cAliasCsv)
						ElseIf "_MSBLQL" $ aKeyCsv[nX] .And. Empty(xValue)
							xValue	:= "2"
						EndIf
						cChavCsv += PadR(IIF(AT( "'", xValue ) == 1, SubStr(xValue,2), xValue),TamSx3(aKeyCsv[nX])[1])
					Next nX
					
					If (cAliasCsv)->(DbSeek(cChavCsv))
						_nCount ++
						FT_FSKIP()
						FWrite(nHandLog, STR0044 + AllTrim(cKeyCsv) + ") (" + cChavCsv + STR0045 + CRLF) //"o registro com chave("###") já existe!"
						Loop
					Else
						aObrigat := {}
						cObrigat := ""
						RecLock(cAliasCsv, .T.)
						For nX := 1 To Len(_aDados)
							If aCabCsv[nX][2] == "N" 
								xValue	:= Val(LimpaAspa(_aDados[nX]))
							ElseIf aCabCsv[nX][2] == "D"
								If "/" $ _aDados[nX]
									xValue	:= CtoD(LimpaAspa(_aDados[nX]))
								Else
									xValue	:= StoD(LimpaAspa(_aDados[nX]))
								EndIf
							ElseIf aCabCsv[nX][2] == "L"
								If xValue == "T"
									xValue	:= .T.
								Else
									xValue	:= .F.
								EndIf									
							Else
								xValue	:= LimpaAspa(_aDados[nX])
								If nX == 145
									FWrite(nHandLog, "Linha " + cValToChar(nX) + CRLF)
								EndIf
								xValue	:= PadR(IIF(AT( "'", xValue ) == 1, SubStr(xValue,2), xValue),TamSx3(aCabCsv[nX][1])[1])
							EndIf
							(cAliasCsv)->&(aCabCsv[nX][1])  := xValue
							//verifica se é um campo obrigatório
							If Empty(xValue) .And. X3Obrigat(aCabCsv[nX][1])
								Aadd(aObrigat, aCabCsv[nX][1])
							EndIf
					    Next nX
					    MsUnlock()
					    If Len(aObrigat) == 0
					    	FWrite(nHandLog, STR0044 + AllTrim(cKeyCsv) + ") (" + cChavCsv + STR0046 + CRLF) //"O registro com a chave ("###") gravado com sucesso"
					    Else
					    	RecLock(cAliasCsv, .F.)
					    	(cAliasCsv)->(DbDelete())
					    	MsUnlock()
					    	For nX := 1 To Len(aObrigat)
					    		If nX > 1
					    			cObrigat += ", "
					    		EndIf
					    		cObrigat += aObrigat[nX]
					    	Next nX
					    	FWrite(nHandLog, STR0044 + AllTrim(cKeyCsv) + ") (" + cChavCsv + STR0047 + cObrigat + ")" + CRLF) //"o registro com a chave ("###"} Erro: campos obrigatórios em branco ("
					    EndIf
					EndIf 
					
				EndIf
					
				_nCount ++
							
				// Pula para próxima linha
				FT_FSKIP()
			Else
				Exit
			EndIf
		EndIf		
	EndDo
	
	// Fecha o Arquivo
	FT_FUSE()
	FWrite(nHandLog, STR0048 + Time() + CRLF) //"Finalizado: "
EndIf

RestArea(_aArea)
	
Return Nil

Static function ArrToStr(_aTexto)
Local cRet := ""
Local nCount := 0

For nCount := 1 to len(_aTexto)

	cRet +=_aTexto[nCount]
          
Next nCount

Return(cRet)

Static Function LimpaAspa(cString)
Local cRet		:= ""
Local cCaracter	:= ""
Local nX		:= 0

Default cString	:= ""

For nX  := 1 To Len(cString)
	cCaracter	:= SubStr(cString,nX,1)
	If Asc(cCaracter) == 34
		Loop
	EndIf
	cRet += cCaracter
Next nX

Return cRet

Static Function ConfereCab(aCabCsv,nHandLog)
Local aAreaSx3	:= SX3->(GetArea())
Local nX		:= 0
Local lRet		:= .T.

(LOCXCONV(1))->(DBSETORDER(2))

For nX := 1 To Len(aCabCsv)
	If ! (LOCXCONV(1))->(DBSEEK(Padr(aCabCsv[nX][1],10)))  .And. !Empty(aCabCsv[nX][1])
		If lRet
			FWrite(nHandLog, Replicate("*",80) + CRLF)
			FWrite(nHandLog, STR0017+" "+STR0049+ CRLF) //"atencao"###"Os campos abaixo relacionados não constam no dicionário de dados"
			FWrite(nHandLog, STR0050 + CRLF) // "verifique o problema e realize a atualização novamente após corrido o mesmo"
			FWrite(nHandLog, Replicate("*",80) + CRLF)
		EndIf
		FWrite(nHandLog, STR0051 + aCabCsv[nX][1] + CRLF) // "Campo:"
		lRet	:= .F.
	EndIf
Next nX

RestArea(aAreaSx3)

Return lRet




/*/{Protheus.doc} LOCA07804
Função para montar a tela de login simplificada
@type function
@author Atilio
@since 17/09/2015
@version 1.0
    @param cUsrLog, Caracter, Usuário para o login (ex.: "admin")
    @param cPswLog, Caracter, Senha para o login (ex.: "123")
    @return lRet, Retorno lógico se conseguiu encontrar o usuário digitado
    @example
    //Verificando se o login deu certo
    If LOCA07804(@cUsrAux, @cPswAux)
        //....
    EndIf
/*/
 
Function LOCA07804(cUsrLog, cPswLog, cInfEmp, cInfFil)
    Local aArea := GetArea()
    Local oGrpLog
    Local oBtnConf
    Private lRetorno := .F.
    Private oDlgPvt
    //Says e Gets
    Private oSayUsr
    Private oGetUsr, cGetUsr := Space(25)
    Private oSayPsw
    Private oGetPsw, cGetPsw := Space(20)
    Private oGetErr, cGetErr := ""
	Private oSayEmp
    Private oGetEmp, cGetEmp := "02" //Space(2)
	Private oSayFil
    Private oGetFil, cGetFil := "0202" //Space(8)
    //Dimensões da janela
    Private nJanLarg := 200
    Private nJanAltu := 280
     
    //Criando a janela				Login
    DEFINE MSDIALOG oDlgPvt TITLE STR0020 FROM 000, 000  TO nJanAltu, nJanLarg COLORS 0, 16777215 PIXEL
        //Grupo de Login
        @ 003, 001     GROUP oGrpLog TO (nJanAltu/2)-1, (nJanLarg/2)-3 PROMPT STR0021     OF oDlgPvt COLOR 0, 16777215 PIXEL //"Login: "
            //Label e Get de Usuário
            @ 013, 006   SAY   oSayUsr PROMPT STR0022 SIZE 030, 007 OF oDlgPvt PIXEL //"Usuário:" 
            @ 020, 006   MSGET oGetUsr VAR    cGetUsr SIZE (nJanLarg/2)-12, 007 OF oDlgPvt COLORS 0, 16777215 PIXEL
         
            //Label e Get da Senha
            @ 033, 006   SAY   oSayPsw PROMPT STR0023 SIZE 030, 007 OF oDlgPvt       PIXEL //"Senha:" 
            @ 040, 006   MSGET oGetPsw VAR    cGetPsw SIZE (nJanLarg/2)-12, 007 OF oDlgPvt COLORS 0, 16777215 PIXEL PASSWORD

			//Label e Get da Senha
            @ 053, 006   SAY   oSayEmp PROMPT STR0024 SIZE 030, 007 OF oDlgPvt                    PIXEL //"Empresa:"
            @ 060, 006   MSGET oGetEmp VAR    cGetEmp SIZE (nJanLarg/2)-12, 007 OF oDlgPvt COLORS 0, 16777215 PIXEL 

			//Label e Get da Senha
            @ 073, 006   SAY   oSayFil PROMPT STR0025 SIZE 030, 007 OF oDlgPvt                    PIXEL //"Filial:"
            @ 080, 006   MSGET oGetFil VAR    cGetFil SIZE (nJanLarg/2)-12, 007 OF oDlgPvt COLORS 0, 16777215 PIXEL 
         
            //Get de Log, pois se for Say, não da para definir a cor
            @ 100, 006   MSGET oGetErr VAR    cGetErr        SIZE (nJanLarg/2)-12, 007 OF oDlgPvt COLORS 0, 16777215 NO BORDER PIXEL
            oGetErr:lActive := .F.
            oGetErr:setCSS("QLineEdit{color:#FF0000; background-color:#FEFEFE;}")
         
            //Botões
            @ (nJanAltu/2)-18, 006 BUTTON oBtnConf PROMPT STR0026 SIZE (nJanLarg/2)-12, 015 OF oDlgPvt ACTION (fVldUsr(cGetEmp,cGetFil)) PIXEL //Confirmar
            oBtnConf:SetCss("QPushButton:pressed { background-color: qlineargradient(x1: 0, y1: 0, x2: 0, y2: 1, stop: 0 #dadbde, stop: 1 #f6f7fa); }")
    ACTIVATE MSDIALOG oDlgPvt CENTERED
     
    //Se a rotina foi confirmada e deu certo, atualiza o usuário e a senha
    If lRetorno
        cUsrLog := Alltrim(cGetUsr)
        cPswLog := Alltrim(cGetPsw)
		cInfEmp	:= cGetEmp
		cInfFil	:= cGetFil
    EndIf
     
    RestArea(aArea)
Return lRetorno
 
/*---------------------------------------------------------------------*
 | Func:  fVldUsr                                                      |
 | Autor: Daniel Atilio                                                |
 | Data:  17/09/2015                                                   |
 | Desc:  Função para validar se o usuário existe                      |
 *---------------------------------------------------------------------*/
 
Static Function fVldUsr(cGetEmp,cGetFil)
    Local cUsrAux := Alltrim(cGetUsr)
    Local cPswAux := Alltrim(cGetPsw)
    Local cCodAux := ""
     
    //Pega o código do usuário
    PswOrder(2)
    If !Empty(cUsrAux) .and. PswSeek(cUsrAux)

		If !Empty(cGetEmp) .And. !Empty(cGetFil)
			cCodAux := PswRet(1)[1][1]
		
			//Agora verifica se a senha bate com o usuário
			PswSeek(cUsrAux)
			If !PswName(cPswAux)
				cGetErr := STR0027 //"Senha inválida!"
				oGetErr:Refresh()
				Return
			
			//Senão, atualiza o retorno como verdadeiro
			Else
				lRetorno := .T.
			endif
			lRetorno := .T.
		Else
			cGetErr := STR0028 //"Informe Empresa e Filial!"
			oGetErr:Refresh()
			Return
		EndIf			
      
     //Senão atualiza o erro e retorna para a rotina
     Else
         cGetErr := STR0029 //"Usuário não encontrado!"
         oGetErr:Refresh()
         Return
    EndIf
     
    //Se o retorno for válido, fecha a janela
    If lRetorno
        oDlgPvt:End()
    EndIf
Return
