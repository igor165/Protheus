#Include "Protheus.Ch"
/*/                
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³RIEX      ³ Autor ³  Sergio S. Fuzinaka   ³ Data ³ 05.02.07 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³RIEX - Registro de Informacoes de Exportacao - XML          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³Nenhum                                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³Nenhum                                                      ³±±
±±³          ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³   DATA   ³ Programador   ³Manutencao Efetuada                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³          ³               ³                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function RIEX()

Local lSigaEEC	:= SuperGetMv("MV_EECFAT")		//Integracao com o Modulo SIGAECC - Exportacao
Local cPerg		:= Padr("RIEX",6)
Local cArq		:= ""
Local aStru		:= {} 

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Cria arquivo temporario                    ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
AADD(aStru,{"DETALHE","C",200,0})
cArq := CriaTrab(aStru)
dbUseArea(.T.,__LocalDriver,cArq,"TMP")

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Perguntas do Sistema                       ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Pergunte(cPerg,.T.)

/*
ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
³Estrutura do documento XML - Exemplo       ³
ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
<?xml version="1.0" encoding="ISO-8859-1"?>
<RegistroExportacao>
	<NfExportacao CFOP="7101" SequenciaTipoSiscomex="1" NF="00001" Serie="1" DataEmissao="01/09/2005" ValorTotal="400" PesoLiquido="12,3" Pais="Argentina">
		<RE RE="053456789001" TipoSiscomex="RE" UFProdutor="SP"/>
		<RE RE="053456789002" TipoSiscomex="RE" UFProdutor="SP"/>
		<RE RE="053456789003" TipoSiscomex="RE" UFProdutor="MG"/>
		<ItemNfExportacao NCM="87120010" Unidade="peça" Quantidade="2" ValorTotalItem="200"/>
		<ItemNfExportacao NCM="52041111" Unidade="metro" Quantidade="500" ValorTotalItem="150"/>
	</NfExportacao>
</RegistroExportacao>
*/

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Verifica a Integracao com o SIGAECC        ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If lSigaEEC
	Processa({|| GeraXml()})
Endif

Return Nil

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³GeraXml    ³ Autor ³  Sergio S. Fuzinaka   ³ Data ³ 05.02.07 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³Gera arquivo XML - Exportacao Direta                         ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function GeraXml()

Local cAlias	:= "SD2"
Local cChave	:= ""
Local aItemNf	:= {}
Local aNivel	:= {5,10,15}	//Nivel de deslocamento - Indentacao
Local cCfop		:= ""
Local lQuery	:= .F.
Local cQuery	:= ""
Local cIndex	:= ""
Local nIndex	:= 0
Local aRE		:= {}
Local cCondicao	:= ""
Local cNfDe		:= mv_par01
Local cNfAte	:= mv_par02
Local cPreemb	:= ""

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Query / Filtro                             ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
#IFDEF TOP
    If TcSrvType() <> "AS/400"
    	lQuery := .T.
    Endif
#ENDIF    

dbSelectArea("SD2")
dbSetOrder(3)

If lQuery
	cCondicao := "%"
	cCondicao += "D2_CF LIKE '7%' AND D2_CF <> '7501' AND"
	cCondicao += "%"

	cAlias := GetNextAlias()
	BeginSql Alias cAlias
		Column D2_EMISSAO as Date
		SELECT D2_FILIAL,D2_EMISSAO,D2_CF,D2_DOC,D2_SERIE,D2_LOJA,D2_CLIENTE,D2_COD,D2_QUANT,D2_TOTAL,D2_PREEMB,D2_PEDIDO,D2_ITEMPV
		FROM %Table:SD2% SD2
		WHERE D2_FILIAL = %Exp:xFilial("SD2")% AND 
			D2_DOC >= %Exp:cNfDe% AND 
			D2_DOC <= %Exp:cNfAte% AND 
			%exp:cCondicao%
			SD2.%NotDel% 
		ORDER BY %Order:SD2%
	EndSql 
	cDebug := GetLastQuery()[2]		//Para debugar a query
Else
	cIndex := CriaTrab(Nil,.F.)
	cQuery := 'D2_FILIAL="'+xFilial("SD2")+'" .And. D2_DOC>="'+cNfDe+'" .And. D2_DOC<="'+cNfAte+'" .And. '
	cQuery += 'Left(Alltrim(D2_CF),1) == "7" .And. Alltrim(D2_CF) <> "7501"'
	
	IndRegua("SD2",cIndex,IndexKey(),,cQuery,Nil,.F.)
	nIndex := RetIndex("SD2")
	dbSetIndex(cIndex+OrdBagExt())
	dbSetOrder(nIndex+1)
	dbGoTop()
Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Tag de inicializacao do documento XML          ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
dbSelectArea("TMP")
RecLock("TMP",.T.)
TMP->DETALHE := '<?xml version="1.0" encoding="ISO-8859-1"?>'
MsUnlock()

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Inicio da Tag do Registro de Exportacao        ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
RecLock("TMP",.T.)
TMP->DETALHE := XMLConv("",,,"RegistroExportacao",.T.,.F.)
MsUnlock()

dbSelectArea(cAlias)
cChave	:= (cAlias)->D2_DOC+(cAlias)->D2_SERIE+(cAlias)->D2_CLIENTE+(cAlias)->D2_LOJA
cCfop   := (cAlias)->D2_CF
cPremb	:= (cAlias)->D2_PREEMB
If !Eof()
	While !Eof()
	
		If (cAlias)->D2_DOC+(cAlias)->D2_SERIE+(cAlias)->D2_CLIENTE+(cAlias)->D2_LOJA+(cAlias)->D2_CF <> cChave 
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Processa/Grava os dados da NF/RE/Itens     ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			ProcNf(cCfop,cChave,aItemNf,aNivel,aRE,cPreemb)
			cChave	:= (cAlias)->D2_DOC+(cAlias)->D2_SERIE+(cAlias)->D2_CLIENTE+(cAlias)->D2_LOJA
			cCfop   := (cAlias)->D2_CF
			cPremb	:= (cAlias)->D2_PREEMB
			aItemNf	:= {}
			aRE		:= {}
		Endif			
	
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Processa RE - Registro de Exportacao           ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If Empty(aRE)
			dbSelectArea("EE9")
			dbSetOrder(3)
			If dbSeek(xFilial("EE9")+(cAlias)->D2_PREEMB)
				While !Eof() .And. EE9_FILIAL+EE9_NF+EE9_SERIE == xFilial("EE9")+(cAlias)->D2_DOC+(cAlias)->D2_SERIE
					If (cAlias)->D2_PEDIDO == Posicione("EE7",1,xFilial("EE7")+EE9->EE9_PEDIDO,"EE7_PEDFAT") .And. ;
						(cAlias)->D2_ITEMPV == Posicione("EE8",1,xFilial("EE8")+EE9->EE9_PEDIDO+EE9->EE9_SEQUEN,"EE8_FATIT")
						dbSelectArea("SA5")
						dbSetOrder(1)
						If dbSeek(xFilial("SA5")+EE9->EE9_FORN+EE9->EE9_FOLOJA+EE9->EE9_COD_I)
							dbSelectArea("SA2")
							dbSetOrder(1)
							If dbSeek(xFilial("SA2")+SA5->A5_FABR+SA5->A5_FALOJA)
								AADD(aRE,{Space(aNivel[2])+'<RE RE="'+EE9->EE9_RE+'" TipoSiscomex="'+"RE"+'" UFProdutor="'+SA2->A2_EST+'"/>'})
							Endif
						Endif
	                Endif
					dbSelectArea("EE9")
					dbSkip()
				Enddo
			Endif
		Endif
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Inicio da Tag de Item da Nf de Exportacao      ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		AADD(aItemNf,{XMLConv("",,,"ItemNfExportacao",.T.,.F.,aNivel[2])})		
		
		dbSelectArea("SB1")
		dbSetOrder(1)
		If dbSeek(xFilial("SB1")+(cAlias)->D2_COD)
			AADD(aItemNf,{XMLConv(SB1->B1_POSIPI,"C",8,"NCM",.T.,.T.,aNivel[3])})	
			dbSelectArea("SAH")
			dbSetOrder(1)
			If dbSeek(xFilial("SAH")+SB1->B1_UM)
				AADD(aItemNf,{XMLConv(SAH->AH_DESCPO,"C",Len(Alltrim(SAH->AH_DESCPO)),"Unidade",.T.,.T.,aNivel[3])})	
		 	Endif
		Endif
		AADD(aItemNf,{Space(aNivel[3])+"<Quantidade>"+Alltrim(Transform((cAlias)->D2_QUANT,StrTran(PesqPict("SD2","D2_QUANT"),",","")))+"</Quantidade>"})
		AADD(aItemNf,{Space(aNivel[3])+"<ValorTotalItem>"+Alltrim(Transform((cAlias)->D2_TOTAL,StrTran(PesqPict("SD2","D2_TOTAL"),",","")))+"</ValorTotalItem>"})
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Fim da Tag de Item da Nf de Exportacao         ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		AADD(aItemNf,{XMLConv("",,,"ItemNfExportacao",.F.,.T.,aNivel[2])})		
	
		dbSelectArea((cAlias))
		dbSkip()
	Enddo
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Processa/Grava os dados da NF/Itens        ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	ProcNf(cCfop,cChave,aItemNf,aNivel,aRE,cPreemb)
Endif
	
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Fim da Tag do Registro de Exportacao           ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
RecLock("TMP",.T.)
TMP->DETALHE := XMLConv("",,,"RegistroExportacao",.F.,.T.)
MsUnlock()

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Deletando Indices/Tabelas Temporarias          ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If lQuery
	dbSelectArea(cAlias)
	dbCloseArea()
	dbSelectArea("SD2")	
Else
	dbSelectArea("SD2")
	RetIndex("SD2")
	dbClearFilter()
	Ferase(cIndex+OrdBagExt())
Endif

Return Nil

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³ProcNf     ³ Autor ³  Sergio S. Fuzinaka   ³ Data ³ 05.02.07 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³Processa dados da Nota Fiscal                                ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function ProcNf(cCfop,cChave,aItemNf,aNivel,aRE,cPreemb)

Local aArea	:= GetArea()
Local aNf	:= {}
Local nX	:= 0

dbSelectArea("SF2")
dbSetOrder(1)
If dbSeek(xFilial("SF2")+cChave)
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Inicio da Tag da Nf de Exportacao              ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	AADD(aNf,{XMLConv("",,,"NfExportacao",.T.,.F.,aNivel[1])})
	AADD(aNf,{XMLConv(cCfop,"C",4,"CFOP",.T.,.T.,aNivel[2])})	

	dbSelectArea("EEC")
	dbSetOrder(1)
	If dbSeek(xFilial("EEC")+cPreemb)
		AADD(aNf,{Space(aNivel[2])+"<SequenciaTipoSiscomex>"+EEC->EEC_TSISC+"</SequenciaTipoSiscomex>"})
	Endif
	
	AADD(aNf,{XMLConv(SF2->F2_DOC,"C",TamSx3("F2_DOC")[1],"NF",.T.,.T.,aNivel[2])})
	AADD(aNf,{XMLConv(SerieNfId('SF2',2,'F2_SERIE'),"C",SerieNfId('SF2',6,'F2_SERIE'),"Serie",.T.,.T.,aNivel[2])})	
	AADD(aNf,{XMLConv(SF2->F2_EMISSAO,"D",10,"DataEmissao",.T.,.T.,aNivel[2])})
	AADD(aNf,{Space(aNivel[2])+"<ValorTotal>"+Alltrim(Transform(SF2->F2_VALBRUT,StrTran(PesqPict("SF2","F2_VALBRUT"),",","")))+"</ValorTotal>"})
	AADD(aNf,{Space(aNivel[2])+"<PesoLiquido>"+Alltrim(Transform(SF2->F2_PLIQUI,StrTran(PesqPict("SF2","F2_PLIQUI"),",","")))+"</PesoLiquido>"})

	dbSelectArea("SA1")
	dbSetOrder(1)
	If dbSeek(xFilial("SA1")+SF2->F2_CLIENTE+SF2->F2_LOJA)
		dbSelectArea("SYA")
		dbSetOrder(1)
		If dbSeek(xFilial("SYA")+SA1->A1_PAIS)
			AADD(aNf,{XMLConv(Alltrim(SYA->YA_DESCR),"C",Len(Alltrim(SYA->YA_DESCR)),"Pais",.T.,.T.,aNivel[2])})			
		Endif
	Endif
Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Grava dados da NF                              ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
For nX:=1 To Len(aNf)
	RecLock("TMP",.T.)	
	TMP->DETALHE := aNf[nX][1]
	MsUnlock()
Next

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Grava itens da RE - Registro de Exportacao     ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
For nX:=1 To Len(aRE)
	RecLock("TMP",.T.)	
	TMP->DETALHE := aRE[nX][1]
	MsUnlock()
Next

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Grava dados dos itens da NF                    ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
For nX:=1 To Len(aItemNf)	
	RecLock("TMP",.T.)		
	TMP->DETALHE := aItemNf[nX][1]
	MsUnlock()
Next

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Fim da Tag de Nf de Exportacao                 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
RecLock("TMP",.T.)		
TMP->DETALHE := XMLConv("",,,"NfExportacao",.F.,.T.,aNivel[1])
MsUnlock()

RestArea(aArea)

Return Nil

