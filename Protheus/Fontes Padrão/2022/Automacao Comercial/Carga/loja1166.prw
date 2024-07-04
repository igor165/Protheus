#INCLUDE "PROTHEUS.CH"
#INCLUDE "LOJA1166.CH"

#DEFINE ENTIRE		"1"  //carga inteira
#DEFINE INCREMENTAL	"2"  //carga incremental

// O protheus necessita ter ao menos uma fun��o p�blica para que o fonte seja exibido na inspe��o de fontes do RPO.
Function LOJA1166() ; Return

/*
��������������������������������������������������������������������������������������������
��������������������������������������������������������������������������������������������
����������������������������������������������������������������������������������������ͻ��
���     Classe: � LJCInitialLoadSBIExporter         � Autor: Vendas CRM � Data: 16/10/10 ���
����������������������������������������������������������������������������������������͹��
���  Descri��o: � Exportador da tabela especial SBI.                                     ���
����������������������������������������������������������������������������������������ͼ��
��������������������������������������������������������������������������������������������
��������������������������������������������������������������������������������������������
*/
Class LJCInitialLoadSBIExporter
	Method New()
	Method Execute()
	Method GeraStrCSV() 
	Method GeraDadoCSV()
	Method CloseArqCSV()        
EndClass

/*
��������������������������������������������������������������������������������������������
��������������������������������������������������������������������������������������������
����������������������������������������������������������������������������������������ͻ��
���     M�todo: � New                               � Autor: Vendas CRM � Data: 16/10/10 ���
����������������������������������������������������������������������������������������͹��
���  Descri��o: � Construtor.                                                            ���
����������������������������������������������������������������������������������������͹��
��� Parametros: � Nenhum.                                                                ���
����������������������������������������������������������������������������������������͹��
���    Retorno: � Self                                                                   ���
����������������������������������������������������������������������������������������ͼ��
��������������������������������������������������������������������������������������������
��������������������������������������������������������������������������������������������
*/
Method New() Class LJCInitialLoadSBIExporter
Return

/*
��������������������������������������������������������������������������������������������
��������������������������������������������������������������������������������������������
����������������������������������������������������������������������������������������ͻ��
���     M�todo: � Execute                           � Autor: Vendas CRM � Data: 16/10/10 ���
����������������������������������������������������������������������������������������͹��
���  Descri��o: � Executa a exporta��o da tabel especial.                                ���
����������������������������������������������������������������������������������������͹��
��� Parametros: � oSpecialTable: Objeto do tipo LJCInitialLoadSpecialTable.              ���
���             � oILMaker: Objeto do tipo LJCInitialLoadMaker que chamou essa execu��o. ���
����������������������������������������������������������������������������������������͹��
���    Retorno: � aResults: Array do tipo LJCInitialLoadMakerTransferFile.               ���
����������������������������������������������������������������������������������������ͼ��
��������������������������������������������������������������������������������������������
��������������������������������������������������������������������������������������������
*/
Method Execute( oSpecialTable, oILMaker ) Class LJCInitialLoadSBIExporter
	Local aResults			:= {}
	Local oResult			:= Nil
	Local cFileNamePath		:= "" 
	Local aStruct			:= {}
	Local nCount			:= 0
	Local nCount2			:= 0
	Local nCount3			:= 0
	Local lRenewTimer		:= .T.
	Local nTotalRecords		:= 0
	Local nSecond1			:= 0
	Local nSecond2			:= 0
	Local nRecordsProcessed	:= 0
	Local nRecord			:= 0
	Local oLJMessageManager	:= GetLJCMessageManager()
	Local lLJ1146Ex			:= ExistBlock( "LJ1146Ex" )
	Local lLJ1166Ex			:= ExistBlock( "LJ1166Ex" )
	Local aNewField			:= {}
	Local lSB1ExclusiveTable:= .F.
	Local lSBIExclusiveTable:= .F.
	Local lSB0ExclusiveTable:= .F.
	Local oTempTable		:= Nil
	Local cGerCSV			:= SuperGetMV("MV_LJGECSV",.F.,"0") //geracao de CSV 0 - N�o gera, 1 - gera dbf/csv, 2 - somente csv
	Local oFrm				:= NIL //Formul�rio CSV
	Local lGeraCSV			:= (cGerCSV == "1" .OR.  cGerCSV == "2") //Gera o arquivo CSV?
	Local cFileCSV			:= "" //Nome do arquivo CSV
	Local aStruct2			:= {} //Estrutura do Arquivo
	Local cFileExt			:= "" //Extens�o do arquivo	
	Local cFilialSBI 		:= ""
	Local cRelease			:= GetRPORelease()	//Release atual
	
	LjGrvLog( "Carga","Exporta tabela especial ")
	LjGrvLog( "Carga","Existe P.E lLJ1146Ex" , lLJ1146Ex)
	LjGrvLog( "Carga","Existe P.E lLJ1166Ex" , lLJ1166Ex)
	LjGrvLog( "Carga","Configura��o do par�metro MV_LJGECSV", cGerCSV)

	If MpDicInDb() .AND. cRelease >= "12.1.025"
		lGeraCSV 	:= .T.
		cGerCSV		:= "2"
		LjGrvLog( "Carga","Release Atual: " + cRelease + " e Dicionario no banco, parametro MV_LJGECSV obrigatoriamente deve assumir a configuracao = '2'")
	EndIf

	/*
	Como o SBI � montado:
	A tabela SBI � uma jun��o do cadastro de produtos (SB1) com o cadastro de pre�os do loja (SB0).
	O front loja aceita os seguintes modos de compartilhamento:
	1 -
		SB1 - Compartilhado
		SBI - Compartilhado
		SB0 - Compartilhado
	2 -
		SB1 - Compartilhado
		SBI - Compartilhado
		SB0 - Exclusivo
	3 -
		SB1 - Exclusivo
		SBI - Exclusivo
		SB0 - Exclusivo
	No modo 1, 1 arquivo � gerado no total, porque o SB0 � compartilhado e a rela��o de cada arquivo � de 1 produto para 1 pre�o.
	No modo 2, 1 arquivo para cada filial � gerado, porque o SB0 � exclusivo, e a rela��o de cada arquivo � de n produtos para x n pre�os (Ou seja, o SBI fica SB1 x SB0).
	No modo 3, 1 arquivo para cada filial � gerado, porque o SB0 � exclusivo, por�m a rela��o de cada arquivo � de 1 produto para 1 pre�o.
	
	Resumindo, no SBI o modo de distribui��o da tabela � determinada pelo SB0, ou seja, se ele for exclusivo, a distribui��o ser� exclusiva e portanto	haver� um arquivo por filial. 
	A filial do SBI continua a respeitar o modo de compartilhamento do SBI
	*/
	
	// Verifica se o tabela � exclusive
	DbSelectArea( "SX2" )
	DbSetOrder( 1 )	
	
	lSB1ExclusiveTable := AllTrim(FWModeAccess("SB1",3)) == "E"			
	lSBIExclusiveTable := AllTrim(FWModeAccess("SBI",3)) == "E"			
	lSB0ExclusiveTable := AllTrim(FWModeAccess("SB0",3)) == "E"			
	
	If ChkFile( oSpecialTable:cTable, .F. )	
		// Abre a tabela de origem
		DbSelectArea( oSpecialTable:cTable )
		
		// Pega a estrutura do banco de dados
	   	aStruct := (oSpecialTable:cTable)->(DBStruct())
	   	
	   	//-----------------------------------------------------------------------------------------------------------------------------------------
	   	//Procura na estrutura os campos MSEXP e HREXP, se nao encontrar, adiciona manualmente os campos na estrutura
	   	//dessa forma, a criacao dos campos fisicamente nao fica obrigatoria na SBI. Essa compatibilidade eh necessaria para que funcione a carga
	   	//antiga em paralelo, para que seja possivel uma implantacao gradual da carga nova.
	   	//-----------------------------------------------------------------------------------------------------------------------------------------
	   	If aScan( aStruct, {|x| Alltrim(Upper(x[1])) == "BI_MSEXP" } ) <= 0
	   		Aadd(aStruct, {"BI_MSEXP", "C", 8, 0})
	   	EndIf
	   	If aScan( aStruct, {|x| Alltrim(Upper(x[1])) == "BI_HREXP" } ) <= 0
	   		Aadd(aStruct, {"BI_HREXP", "C", 8, 0})
	   	EndIf
	   	
	   	//Adiciona na estrutura o campo DEL pra poder controlar os registros deletados
	   	AADD(aStruct, {"DEL", "C", 1 , 0} ) 
	   	
		cFileExt := LJILRealExt()

		For nCount := 1 To Len( oSpecialTable:aParams[1] )
			aStruct2 := {}
			If !oLJMessageManager:HasError()
				oResult			:= LJCInitialLoadMakerTransferFile():New( oSpecialTable:cTable, cEmpAnt, AllTrim(oSpecialTable:aParams[1][nCount]) )
				nRecord 		:= 0
				cFileNamePath	:= oILMaker:cRootPath + oResult:GetFileWithoutExtension() + cFileExt
				
				If cGerCSV <> "2"
					// Cria o arquivo tempor�rio
					DbCreate( cFileNamePath, aStruct, LJILRealDriver() )
				EndIf

				If lGeraCSV
					cFileCSV :=  oILMaker:cRootPath + oResult:GetFileWithoutExtension() + ".csv"
					oFrm := Self:GeraStrCSV(lGeraCSV, aStruct, cFileCSV, @aStruct2)
				EndIf	

				If ( cGerCSV <> "2" .AND. File( cFileNamePath )  ) .OR. lGeraCSV 

					// Abre a area com o arquivo novo
					If cGerCSV <> "2"							
						DbUseArea( .T., LJILRealDriver(), cFileNamePath, "TRB", .F., .F. )
					EndIf
					
					If (cGerCSV <> "2" .AND. Used()) .or. lGeraCSV 
												
						DbSelectArea("SB1")
						
						// Transporta o banco de dados para o arquivo local
						If lSBIExclusiveTable
							cFilialSBI := oSpecialTable:aParams[1][nCount]
						Else
							cFilialSBI := xFilial("SBI")
						EndIf
									
						oILMaker:oProgress:nStatus := 5	
						oILMaker:Notify()	
						
						oTempTable := LJCInitialLoadTempTableExport():New(oSpecialTable, oSpecialTable:aParams[1][nCount], oILMaker:cExportType, "SB1TMP")
						oTempTable:CreateTempTable()
											
						oTempTable:SetQtyRecords()
						
						nTotalRecords := oTempTable:nQtyRecords
						oILMaker:oProgress:nTotalRecords := nTotalRecords		
						
						oILMaker:oProgress:nStatus := 2	
						oILMaker:Notify()	
						
						//exporta os registros								
						Dbselectarea("SB1TMP") 
						DbGoTop() 
						While SB1TMP->(!EOF()) 
						
							nRecord++
							
							If lLJ1146Ex
								If !ExecBlock( "LJ1146Ex", .F., .F., { oSpecialTable:cTable, oSpecialTable:aParams[1][nCount] } )
									SB1TMP->(DbSkip())
									Loop
								EndIf
							EndIf
							
							If !Empty(oSpecialTable:aParams[2]) .And. !SB1TMP->&(oSpecialTable:aParams[2])
								SB1TMP->(DbSkip())
								Loop
							EndIf				
						
							If lRenewTimer
								nSecond1			:= Seconds()
								nRecordsProcessed	:= 0
								lRenewTimer 		:= .F.
							EndIf			
							
							If cGerCSV <> "2" 
								RecLock( "TRB", .T. )
								For nCount2:= 1 To Len(aStruct)	
									If aStruct[nCount2][1] == "BI_FILIAL"
										TRB->(FieldPut(FieldPos(aStruct[nCount2][1]) , cFilialSBI ))
									ElseIf aStruct[nCount2][1] == "BI_MSEXP"
										TRB->(FieldPut(FieldPos(aStruct[nCount2][1]) , DtoS(dDataBase) ))					
									ElseIf aStruct[nCount2][1] == "BI_HREXP"
										TRB->(FieldPut(FieldPos(aStruct[nCount2][1]) , Left(Time(),8) ))					
									ElseIf aStruct[nCount2][1] == "DEL"
										TRB->(FieldPut(FieldPos(aStruct[nCount2][1]) ,  SB1TMP->( FieldGet( FieldPos( 'DEL' ) ) )   ))
									Else
										If SB1TMP->(FieldPos( "B1" + SubStr(aStruct[nCount2][1],3))) > 0
											TRB->(FieldPut(FieldPos(aStruct[nCount2][1]) , SB1TMP->( FieldGet( FieldPos( "B1" + SubStr(aStruct[nCount2][1],3) ) ) ) ) )
										EndIf
									EndIf
								Next
								
								If lLJ1166Ex
									aNewField := ExecBlock( "LJ1166Ex", .F., .F., {"SB1TMP"} )
									If !ValType(aNewField) <> "A"
										For nCount3 := 1 to Len(aNewField)
											If SB1TMP->(FieldPos( "B1" + SubStr(aNewField[nCount3][1],3))) > 0 
												TRB->(FieldPut(FieldPos(aNewField[nCount3][1]) , aNewField[nCount3][2]))
											EndIf
										Next	
									EndIf
								EndIf
								
								MsUnLock()
							EndIf
							
							//Gera��o de dados em csv								
							Self:GeraDadoCSV(lGeraCSV, aStruct2, "SB1TMP", @oFrm, cFilialSBI)

							nSecond2 := Seconds()
							
							If nSecond2 - nSecond1 >= 1
								lRenewTimer := .T.
								// Avisa a todos os interessando o progresso da gera��o da carga inicial			
								oILMaker:oProgress:nActualRecord := nRecord
								oILMaker:oProgress:nRecordsPerSecond := Int( nRecordsProcessed / (nSecond2-nSecond1) )
								oILMaker:Notify()
							EndIf
									
							SB1TMP->(DbSkip())
							nRecordsProcessed++
						End
						
						Self:CloseArqCSV(lGeraCSV, oFrm)

						//Atualiza a quantidade de registros exportados na MBV
						oILMaker:UpdateQtyRecExport(oSpecialTable,oSpecialTable:aParams[1][nCount], nRecord)
						
						// Avisa a todos os interessando o progresso da gera��o da carga inicial			
						oILMaker:oProgress:nActualRecord := nRecord
						oILMaker:oProgress:nRecordsPerSecond := Int( nRecordsProcessed / (nSecond2-nSecond1) )
						oILMaker:Notify()						
						
						If !oLJMessageManager:HasError()
							oResult:nRecords := nRecord
							aAdd( aResults, oResult )
						EndIf	
						
						//Se for a primeira exportacao da tabela ou for incremental, atualiza os campos MSEXP dos registros exportados 
						If ( oTempTable:IsFirstExport() ) .OR. ( oILMaker:cExportType == INCREMENTAL )
							oILMaker:oProgress:nStatus := 6
							oILMaker:Notify()	
							oTempTable:UpdateMSEXP()
						EndIf

						SB1TMP->(dbCloseArea())  // fecha arquivo temporario com os registros

						If cGerCSV <> "2"
							TRB->(DbCloseArea())
						EndIf	
					Else 
						oLJMessageManager:ThrowMessage( LJCMessage():New("LJCInitialLoadMakerConnotOpenCreatedTable", 1, STR0001 + " '" + cFileNamePath + "'. " + STR0002) ) // "O arquivo de dados foi criado, mas n�o foi poss�vel sua abertura " "O driver utilizado pode estar errado."
					EndIf
				Else
					oLJMessageManager:ThrowMessage( LJCMessage():New("LJCInitialLoadMakerConnotCreateTable", 1, STR0003 + " '" + cFileNamePath + "'. " + STR0004) ) // "N�o foi poss�vel criar o arquivo " "O diret�rio pode estar protegido contra grava��o, ou n�o h� espa�o livre."
				EndIf 
			EndIf					
		Next				
		(oSpecialTable:cTable)->(DbCloseArea())
	Else
		oLJMessageManager:ThrowMessage( LJCMessage():New("LJCInitialLoadMakerConnotOpenTable", 1, STR0005 + " '" + oSpecialTable:cTable + "'. " + STR0006) ) // "N�o foi poss�vel abrir a tabela" "Ela pode estar aberta de modo exclusivo por outro programa."
	EndIf
	
Return aResults

//--------------------------------------------------------------------------------
/*/{Protheus.doc} GeraStrCSV
Cria o arquivo CSV.

@type method
@author Alberto Deviciente
@since 22/04/2020
@version P12

@param lGeraCSV, L�gico, Gera arquivo CSV
@param aStruct, Array, Estrutura do arquivo
@param cFileCSV, Caractere, Nome do arquivo
@param aStruct2, Array, Estrutura 2 do arquivo (sem campos do tipo Memo)
 
@return oFrm, Objeto, Informa��es do Arquivo (handle, header, Numero de Linhas, Nome do arquivo)
/*/
//--------------------------------------------------------------------------------    
Method GeraStrCSV(lGeraCSV, aStruct, cFileCSV, aStruct2) Class LJCInitialLoadSBIExporter
Local nC 		:= 0
Local nTotStru 	:= 0
Local oFrm 		:= {}
Local aHeader 	:= {}
Local nHandle 	:= 0
Local cLinha	:= ""

If lGeraCSV
	nTotStru := Len(aStruct)
	For nC := 1 to nTotStru
		If aStruct[nC, 2] <> "M"
			aADD(aHeader, aStruct[nC, 1])
			aAdd(aStruct2, aClone(aStruct[nC]))
		EndIf
	Next
	
	If File(cFileCSV)
		FErase(cFileCSV)
	EndIf

	nHandle := FCreate(cFileCSV)
	oFrm := {nHandle,aHeader, 0, cFileCSV}
	If nHandle <> -1
		For nC := 1 to Len(aHeader)
			cLinha := cLinha + aHeader[nC]+";"
		Next
		
		cLinha := Substr(cLinha, 1, Len(cLinha)-1) + CRLF
		fWrite(oFrm[1], cLinha)
		oFrm[3] := oFrm[3] + 1
	EndIf
EndIf

Return oFrm

//--------------------------------------------------------------------------------
/*/{Protheus.doc} GeraDadoCSV
Grava a linha do aquivo CSV.

@type method
@author Alberto Deviciente
@since 22/04/2020
@version P12

@param lGeraCSV, L�gico, Gera arquivo CSV
@param aStruct2, Array, Estrutura do arquivo (sem campos do tipo Memo)
@param cAliasTemp, Caractere, Alias tempor�rio
@param oFrm, Objeto, Informa��es do Arquivo (handle, header, Numero de Linhas, Nome do arquivo)
@param cFilialSBI, Caracter, C�digo da filial da tabela SBI

@return Nil, Nulo
/*/
//--------------------------------------------------------------------------------    
Method GeraDadoCSV(lGeraCSV, aStruct2, cAliasTemp, oFrm, cFilialSBI) Class LJCInitialLoadSBIExporter
Local nX 		:= 0
Local uDado 	:= Nil
Local cLinha 	:= ""
Local nColunas 	:= 0

If lGeraCSV
 
	For nX := 1 To Len(aStruct2)
		uDado := Nil
		
		If aStruct2[nX][1] == "BI_FILIAL"
			uDado :=  cFilialSBI
		ElseIf aStruct2[nX][1] == "BI_MSEXP"
			uDado :=  DtoS(dDataBase)
		ElseIf aStruct2[nX][1] == "BI_HREXP"
			uDado :=  Left(Time(),8)
		ElseIf aStruct2[nX][1] == "DEL"
			uDado :=  (cAliasTemp)->( FieldGet( Columnpos( "DEL" ) ) )
		Else
			If (cAliasTemp)->(Columnpos( "B1" + SubStr(aStruct2[nX][1],3))) > 0
				uDado := (cAliasTemp)->(FieldGet(Columnpos( "B1" + SubStr(aStruct2[nX][1],3) )))
			EndIf
		EndIf

		If uDado == Nil
			Do Case
				Case aStruct2[nX][2] == "C"
					uDado := ""
				Case aStruct2[nX][2] == "N"
					uDado := 0
				Case aStruct2[nX][2] == "D"
					uDado := cToD("  /  /  ")
				Case aStruct2[nX][2] == "L"
					uDado := .F.
			EndCase
		EndIf

		uDado := LjCSVConvtype(uDado, aStruct2[nX][2], aStruct2[nX][3], .F., aStruct2[nX][4])
		cLinha := cLinha + uDado + ";"
		nColunas++
	Next nX

	If nColunas == Len(oFrm[2])
		cLinha := Substr(cLinha, 1, Len(cLinha)-1) + CRLF
		If oFrm[3] == 5000
			fClose(oFrm[1])
			oFrm[1] := FOpen(oFrm[4],2)
			FSeek(oFrm[1], 0, 2) //Posiciona no final do arquivo
			oFrm[3] := 0
		EndIf
		If oFrm[1] <> -1
			FWrite(oFrm[1], cLinha, Len(cLinha))
			oFrm[3] := oFrm[3]+1
		EndIf	
	EndIf						
EndIf

Return

//--------------------------------------------------------------------------------
/*/{Protheus.doc} CloseArqCSV
Fecha o aquivo CSV.

@type method
@author Alberto Deviciente
@since 22/04/2020
@version P12

@param lGeraCSV, L�gico, Indica se gera o arquivo CSV
@param oFrm, Objeto, Informa��es do Arquivo (handle, header, Numero de Linhas, Nome do arquivo)

@return Nil, Nulo
/*/
//--------------------------------------------------------------------------------    
Method CloseArqCSV(lGeraCSV, oFrm)  Class LJCInitialLoadSBIExporter

If lGeraCSV
	If oFrm[1] <> -1
		FClose(oFrm[1])
	EndIf
EndIf

Return