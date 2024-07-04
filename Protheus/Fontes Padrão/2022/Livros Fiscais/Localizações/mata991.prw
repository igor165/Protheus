#INCLUDE "mata991.ch"        
#INCLUDE "PROTHEUS.CH"
   
#DEFINE CRLF Chr(13)+Chr(10)
//Posicoes do array com os dados dos arquivos que serao gravados
#DEFINE FAC_EMICAB  01
#DEFINE FAC_EMIDET  02
#DEFINE REG_REGVEN  03
#DEFINE REG_REGCOM  04
#DEFINE OTR_PERCEP  05   
#DEFINE LOG_ERROS   06  
#DEFINE MAX_DEFINE  06  
//Posicoes do array de impostos
#DEFINE IVA  01 
#DEFINE RNI  02 
#DEFINE PIB  03    
#DEFINE PIN  04    
#DEFINE PIM  05    
#DEFINE PII  06    
#DEFINE IVP  07   
#DEFINE MAX_DEFIMP  07 
/*  
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
±±³ PROGRAMADOR  ³ DATA   ³ BOPS    ³  MOTIVO DA ALTERACAO                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Luis Enriquez ³10/01/17³SERINN001³Se realiza merge para hacer cambios  ³±±
±±³              ³        ³-756     ³para creacion de tablas temp. CTREE  ³±±
±±³Marco A. Glz R³23/01/17³MMI-6012 ³Se modifica fLstBoxImps(), debido a  ³±±
±±³              ³        ³         ³que no permitia cerrar la ventana    ³±±
±±³              ³        ³         ³tras seleccionar impuestos. (ARG)    ³±±
±±ÈÍÍÍÍÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function MATA991() 

Local cPerg   := "MTA991" 
Local lParOk  := .F.             
Local cParam  := ""
Local nI := 0
Local nX := 0
Local nY := 0
Local nTam := 0                              
Local aDarq
Private lQuery := .F.
Private lTab   := .F.         
Private nDecimais := MsDecimais(1)
Private cDSucur:= SPACE(TAMSX3("F3_FILIAL")[1])
Private cASucur:= SPACE(TAMSX3("F3_FILIAL")[1])
Private cSDoc  := SerieNfId ('SF3',3,'F3_SERIE')
Private oTmpTable := Nil
Private aOrdem := {}

//Verifica se eh uma base TopConnect
#IFDEF TOP
	If TCSrvType() != "AS/400"
		lQuery := .T.
	EndIf
#ENDIF	

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Carrega as perguntas selecionadas                            ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ mv_par01 - Ano para geracao    ?                            ³
//³ mv_par02 - Mes para geracao    ?                            ³ 
//| mv_par03 - De Filial           ?                            ³  
//| mv_par04 - A Filial            ?                            ³ 
//| mv_par05 - Diretorio de Gravacao                            |
//| mv_par06 - Impostos IVA                                     |
//| mv_par07 - Impostos RNI                                     |
//| mv_par08 - Ingresso Brutos                                  |
//| mv_par09 - Impostos Nacionais                               |
//| mv_par10 - Impostos Municipais                              |
//| mv_par11 - Impostos Internos                                | 
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
While !lParOk 
	lParOk := .T.	
	If !Pergunte(cPerg,.T.)
		Return
	EndIf
	
	cDSucur:= MV_PAR03 
	cASucur:= MV_PAR04
	
	//Valida se o mes informado eh um mes valido...	
	If !(AllTrim(MV_PAR02)$"1|2|3|4|5|6|7|8|9|10|11|12")
		MsgAlert(STR0009) //"Informe um mes valido!"
		lParOk := .F.
		Loop
	EndIf

	//Verifica se as categorias de impostos foram configuradas corretamente...
	nTam   := TamSX3("FB_CODIGO")[1]
	For nI := 4 To 9
		cParam := AllTrim(&("MV_PAR0"+Str(nI,1)))
		For nX := 1 To Len(cParam)
			cImp := SubStr(cParam,nX,nTam)
			For nY := 4 To 9
				If nY <> nI
					If cImp$AllTrim(&("MV_PAR0"+Str(nY,1)))
						MsgAlert(OemToAnsi(STR0026)+cImp+OemToAnsi(STR0027)) //"O imposto "#cImp#" esta compondo mais de uma categoria. Por favor, para continuar com o processo, acerte os parametros."
						lParOk := .F.
						Exit
					EndIf
				EndIf
				If !lParOk
					Exit
				EndIf
			Next nY
			If !lParOk
				Exit
			EndIf
			nX += (nTam)
		Next nX
		If !lParOk
			Exit
		EndIf
	Next nI
	
	If !lParOk
		Loop
	EndIf
			     
	//Verifica se o diretorio informado para gravacao existe...
	If !Empty(MV_PAR05)
		If Left(MV_PAR05,1) <> "\"
			MV_PAR05 := Upper(CurDir())+"\"+Upper(RTrim(MV_PAR05))
		Else
			MV_PAR05 := Upper(CurDir())+Upper(RTrim(MV_PAR05))  //SubStr(Upper(Rtrim(MV_PAR04)),2,Len(Rtrim(MV_PAR04)))
		EndIf

		If !ExistDir(MV_PAR05)  
			MsgInfo(OemToAnsi(STR0030)) //"O diretorio informado para a gravacao dos arquivo nao existe. E necessario cria-lo para depois seguir com o processamento dos dados."
			lParOk := .F.
			Loop
		Else
			If Right(MV_PAR05,1) <> "\"
				MV_PAR05 += "\"
			EndIf
		EndIf
    Else
    	MV_PAR05 := GetSrvProfString("Startpath","")+"\"
	EndIf
End

//Cria o novo indice para o arquivo SF1                
//AjustaSIX()

//Chama funcao que realiza o filtro dos dados com base no arquivo SF3...
Processa({|| aDarq := GeraDados()}, STR0001, STR0002) //"Verificando dados e Gerando os arquivos..."###"Aguarde, por favor..."

If !lTab
	//Informa sobre o fim do processo
	MsgInfo(STR0003) //"Fim do processo de geracao dos arquivos."
Else
	If MsgYesNo(STR0053) // //'Houve problemas na geracao dos arquivos, deseja ver o arquivo de LOG ?'
		MostraErro(Alltrim(MV_PAR05)+aDarq[LOG_ERROS][1])
	Endif	
Endif

Return Nil

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ GeraDados    ³Autor ³ Julio Cesar          ³Data³ 13/05/03 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Filtra os dados existentes no arquivo SF3 e chama a funcao ³±±  
±±³          ³ que ira gerar o arquivo correspondente.                    ³±± 
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function GeraDados()
             
//Variaveis locais
Local aAreaSF3 := SF3->(GetArea())
Local aAreaAtu := GetArea()
Local aDArq    := Array(MAX_DEFINE,03) 
Local aStru    := {}
Local cSerie   := "A"+Space(TamSX3("F3_SERIE")[1]-1)
Local cNota    := Replicate("0",TAMSX3("F3_NFISCAL")[1])
Local cIndex   := ""  
Local cChave   := ""
Local cQuery   := ""
Local cFil     := ""
Local nIndex   := 0
Local cNotaAtu := ""
Local nRegAtu  := 0
Local cArqTmp  := ""
Local cAliasTmp:= ""
Local cArqCom  := ""
Local cAliasCom:= ""
Local nI := 0
Local nPos     := 0
Local dDtComp  := Ctod("//")
Local lCompras := .F.
Local lEmtidas := .F.
Local lVendas  := .F.
Local nCposCom := 0
Local nCposVen := 0
Local cNomeCpo := ""
Local cNewQuery := "" 
Local cResFilA := cFilAnt

//Variaveis Private
Private cAliasSF3 := ""
Private cMes      := If(Len(AllTrim(MV_PAR02))==1,"0","")+AllTrim(MV_PAR02)
Private cData     := MV_PAR01+cMes+"01"
Private cDataFim  := MV_PAR01+cMes+UltDiaMes()
Private aDImps    := Array(MAX_DEFIMP,03)
Private lFormProp := .F.

//Chama funcao que cria os arrays de impostos...
CriaArrayImp()

//Funcao que cria o array com os dados referentes aos arquivos .txt e tambem
//chama a funcao responsavel pela criacao fisica dos arquivos .txt
If !CriaArqTxt(@aDArq)
	Return
EndIf   

SF1->(DbSetOrder(1))
SF2->(DbSetOrder(1))

//Cria arquivo para selecao do livro fiscal e ordena-lo por ordem de emissao + comprovante + fatura
lEmitidas := (MV_PAR13 == 1 .Or. MV_PAR13 == 4)
lVendas   := (MV_PAR13 == 2 .Or. MV_PAR13 == 4)
lCompras  := (MV_PAR13 == 3 .Or. MV_PAR13 == 4)
aStru := SF3->(dbStruct())
Aadd(aStru,{"EMISSAO"	,"C",10,0})
Aadd(aStru,{"COMPROV"	,"C",02,0})
//Arquivo temporario para os registros de EMITIDAS / VENDAS
If  lEmitidas .Or. lVendas
	cAliasTmp := "TMP911A"
	oTmpTable := FWTemporaryTable():New(cAliasTmp) 
	oTmpTable:SetFields( aStru ) 
	aOrdem	:=	{"EMISSAO","COMPROV","F3_NFISCAL"}
	oTmpTable:AddIndex("I1", aOrdem)
	oTmpTable:Create()
	nCposVen := FCount()
Endif
//Arquivo temporario para os registros de COMPRAS
If lCompras
	cAliasCom := "TMP911B"
	oTmpTable := FWTemporaryTable():New(cAliasCom) 
	oTmpTable:SetFields( aStru ) 
	aOrdem	:=	{"EMISSAO","COMPROV","F3_NFISCAL"}
	oTmpTable:AddIndex("I1", aOrdem)
	oTmpTable:Create()
	nCposCom := FCount()
Endif
DbSelectArea("SF3")

//Cria um indice temporario para que os dados sejam gravados na ordem correta
//nos seus respectivos arquivos.
If !lQuery
	//Cria o arquivo temporario...	
	cIndex  := CriaTrab(Nil,.f.)
	//Monta a chave do indice temporario...
	cChave  := "F3_FILIAL+Dtos(F3_ENTRADA)+F3_SERIE+F3_NFISCAL+F3_CLIEFOR+F3_LOJA+Dtos(F3_DTCANC)+F3_ESPECIE" 
	//Monta o filtro para o arquivo...
	cQuery := "F3_FILIAL >=  '"+cDSucur+"' .And. F3_FILIAL <=  '"+cASucur+"' .And. "
	cQuery += "F3_NFISCAL >= '"+cNota+"' .And. " 
	cQuery += cSDoc+" >= '"+cSerie+"' .And. " //modificado por Tiago Silva em 13/05/2015 PRJ Chave Unica
	cQuery += "Dtos(F3_ENTRADA) >= '"+cData+"' .And. Dtos(F3_ENTRADA) <= '"+cDataFim+"'"
	If !(lCompras .Or. lEmitidas)
		cQuery += " .And. F3_TIPOMOV == 'V'"
	Endif 
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ0
	//³Ponto de entrada M991QUERY altera a query original³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ0
	If ExistBlock("M991QUERY")
		cNewQuery := ExecBlock("M991QUERY",.F.,.F.,{cQuery})
		If Valtype(cNewQuery) == "C"
			cQuery := cNewQuery
		Endif
	EndIf
	
	//Filtra os dados do arquivo...
	IndRegua("SF3",cIndex,cChave,,cQuery,STR0004) //"Selecionando Registros..." //"Selecionando Registros..."
	
	nIndex := RetIndex("SF3")
	dbSelectArea("SF3")
	dbSetIndex(cIndex+OrdBagExt())
	dbSetOrder(nIndex+1)
	                    
	//Define o alias para o arquivo SF3
	cAliasSF3 := "SF3"
	SF3->(DbGotop())
Else
	cQuery := "SELECT *"
	cQuery += " FROM " + RetSQLName("SF3") 
	cQuery += " WHERE (F3_FILIAL >='"+cDSucur+"'  AND F3_FILIAL <='"+cASucur+ "' ) AND"
	cQuery += " F3_NFISCAL >= '"+cNota+"' AND " 	
	cQuery += cSDoc+"   >= '"+cSerie+"' AND" //modificado por Tiago Silva em 13/05/2015 PRJ Chave Unica
	cQuery += " F3_ENTRADA BETWEEN '"+cData+ "' AND '"+cDataFim+"' AND" 
	If !(lCompras .Or. lEmitidas)
		cQuery += " F3_TIPOMOV = 'V' AND"
	Endif
	cQuery += " D_E_L_E_T_ = ' '"
	cQuery += " ORDER BY F3_FILIAL,F3_ENTRADA,F3_SERIE,F3_NFISCAL,F3_CLIEFOR,F3_LOJA,F3_DTCANC,F3_ESPECIE"	 
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ0
	//³Ponto de entrada M991QUERY altera a query original³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ0
	If ExistBlock("M991QUERY")
		cNewQuery := ExecBlock("M991QUERY",.F.,.F.,{cQuery})
		If Valtype(cNewQuery) == "C"
			cQuery := cNewQuery
		Endif
	EndIf
	
	
	cQuery := ChangeQuery(cQuery)
	dbUseArea( .T., "TOPCONN", TCGenQry(,,cQuery), 'SF3TMP', .F., .T.)	

	//Acerta os campos conforme o seu tipo...           
	
	dbSelectArea("SF3TMP")
	For nI := 1 To Len(aStru)
		If aStru[nI][2] != "C" .And. FieldPos(aStru[nI][1]) != 0
			TCSetField("SF3TMP", aStru[nI][1], aStru[nI][2], aStru[nI][3], aStru[nI][4])
		EndIf
	Next nI           

	//Define o alias para o arquivo SF3
	cAliasSF3 := "SF3TMP"               
EndIf

//Verifica todos os registros, apos filtra-los, no arquivo SF3...
nRegAtu := 0
ProcRegua(10)
While !Eof()
	cFilAnt:= (cAliasSF3)->F3_FILIAL       
	nRegAtu++      
	If nRegAtu == 10
		ProcRegua(10)
		nRegAtu := 0
	EndIf
	//Verifica se eh a mesma nota pois cada nota pode ser verificada
	//uma unica vez...
	If cNotaAtu <> (cAliasSF3)->(F3_FILIAL+Dtos(F3_ENTRADA)+F3_SERIE+F3_NFISCAL+F3_CLIEFOR+F3_LOJA+Dtos(F3_DTCANC)+F3_ESPECIE)
		cNotaAtu := (cAliasSF3)->(F3_FILIAL+Dtos(F3_ENTRADA)+F3_SERIE+F3_NFISCAL+F3_CLIEFOR+F3_LOJA+Dtos(F3_DTCANC)+F3_ESPECIE)
		//Determina se a factura ou nota foi impressa em formulario proprio...	
		lFormProp := FormProp((cAliasSF3)->F3_ESPECIE,(cAliasSF3)->F3_TIPOMOV,(cAliasSF3)->F3_TES,(cAliasSF3)->F3_FORMUL)
		//Caso a factura ou nota esteja cancelada e nao se trata de formulario 
		//proprio nao existe de inclui-la nos arquivos...
		If lFormProp .Or. Empty((cAliasSF3)->F3_DTCANC)
			If lEmitidas .Or. lVendas
				DbSelectArea(cAliasTmp)
				RecLock(cAliasTmp,.T.)
				For nI := 1 to nCposVen
					cNomeCpo := (cAliasTmp)->(FieldName(nI))
					nPos := (cAliasSF3)->(FieldPos(cNomeCpo))
					If nPos > 0
						FieldPut(nI,(cAliasSF3)->&(cNomeCpo))
					Endif
				Next
				Replace EMISSAO	With Dtos((cAliasSF3)->F3_ENTRADA)
				Replace COMPROV	With M991TpComp(If((cAliasSF3)->F3_TES > "500","SD2","SD1"),(cAliasSF3)->F3_SERIE,(cAliasSF3)->F3_ESPECIE)
				MsUnLock()
			Endif
			//Geracao dos registros para o arquivo COMPRAS
			If (cAliasSF3)->F3_TIPOMOV == "C"
				If lCompras
					dDtComp := (cAliasSF3)->F3_ENTRADA
					If (cAliasSF3)->F3_TES > "500"
						DbSelectArea("SF2")
						//DbSeek(xFilial("SF2")+(cAliasSF3)->F3_NFISCAL+(cAliasSF3)->F3_SERIE+(cAliasSF3)->F3_CLIEFOR+(cAliasSF3)->F3_LOJA)
						DbSeek((cAliasSF3)->F3_FILIAL+(cAliasSF3)->F3_NFISCAL+(cAliasSF3)->F3_SERIE+(cAliasSF3)->F3_CLIEFOR+(cAliasSF3)->F3_LOJA)
						If !Empty(SF2->F2_DTLANC)
							cDtComp := SF2->F2_DTLANC
						Endif
					Else
						DbSelectArea("SF1")
						//DbSeek(xFilial("SF1")+(cAliasSF3)->F3_NFISCAL+(cAliasSF3)->F3_SERIE+(cAliasSF3)->F3_CLIEFOR+(cAliasSF3)->F3_LOJA)
						DbSeek((cAliasSF3)->F3_FILIAL+(cAliasSF3)->F3_NFISCAL+(cAliasSF3)->F3_SERIE+(cAliasSF3)->F3_CLIEFOR+(cAliasSF3)->F3_LOJA) 
						If !Empty(SF1->F1_DTLANC)
							cDtComp := SF1->F1_DTLANC
						Endif
					Endif
					DbSelectArea(cAliasCom)
					RecLock(cAliasCom,.T.)
					For nI := 1 to nCposCom
						cNomeCpo := (cAliasCom)->(FieldName(nI)) 
						nPos := (cAliasSF3)->(FieldPos(cNomeCpo))
						If nPos > 0
							FieldPut(nI,(cAliasSF3)->&(cNomeCpo))
						Endif
					Next
					Replace EMISSAO	With Dtos(dDtComp)
					Replace COMPROV	With M991TpComp(If((cAliasSF3)->F3_TES > "500","SD2","SD1"),(cAliasSF3)->F3_SERIE,(cAliasSF3)->F3_ESPECIE)
					MsUnLock()
				Endif
			Endif
		Endif
	EndIf
	DbSelectArea(cAliasSF3)
	dbSkip()
End
If !lQuery
	DbSelectArea("SF3")
	RetIndex("SF3")
	DbClearFilter()
	FErase(cIndex+OrdBagExt())
Else
	DbSelectArea(cAliasSF3)
	dbCloseArea()
EndIf

//Caso nao sejam encontrados dados para a geracao do arquivo a rotina eh abortada.
If ((lEmitidas .Or. lVendas) .And. (cAliasTmp)->(Eof())) .And. (lCompras .And. (cAliasCom)->(Eof()))
	MsgInfo(OemToAnsi(STR0025)) //"Nao foram encontrados dados para a geracao dos arquivos."
Else
	//Verifica todos os registros, apos filtra-los, no arquivo SF3...
	nRegAtu := If(lVendas .Or. lEmitidas,(cAliasTmp)->(RecCount()),0) + If(lCompras,(cAliasCom)->(RecCount()),0)
	ProcRegua(nRegAtu)
	nRegAtu := 0
	If lEmitidas .Or. lVendas
		cAliasSF3 := cAliasTmp
		DbSelectArea(cAliasTmp)
		DbGoTop()
		While !Eof() 
			cFilAnt:= (cAliasSF3)->F3_FILIAL
			//Determina que mais um registro foi lido pela rotina
			nRegAtu++
			//Exibe a factura que esta sendo processada...
			IncProc(STR0065+(cAliasSF3)->F3_NFISCAL+STR0066+(cAliasSF3)->F3_SERIE+"...") //"Procesando Factura: "#" Serie: " 
		
			lFormProp := FormProp((cAliasSF3)->F3_ESPECIE,(cAliasSF3)->F3_TIPOMOV,(cAliasSF3)->F3_TES,(cAliasSF3)->F3_FORMUL)
			//Gera o arquivo de Facturas Emitidas, caso seja formulario proprio...
			If  lFormProp .And. lEmitidas
				GeraDadFEmi(F3_NFISCAL,F3_SERIE,F3_CLIEFOR,F3_LOJA,F3_ENTRADA,F3_DTCANC,@aDArq,F3_TES)
			EndIf
			If F3_TIPOMOV == "V"
				//Gera o arquivo de Vendas
				If lVendas
					GeraDadVen(F3_NFISCAL,F3_SERIE,F3_CLIEFOR,F3_LOJA,F3_ENTRADA,F3_DTCANC,@aDArq,F3_TES)
				EndIf
			EndIf
			DbSelectArea(cAliasSF3)
			dbSkip()
		End
	Endif
	//Geracao do arquivo COMPRAS
	If lCompras
		cAliasSF3 := cAliasCom
		DbSelectArea(cAliasCom)
		DbGoTop()
		While !Eof()
			cFilAnt:= (cAliasSF3)->F3_FILIAL
			nRegAtu++
			IncProc(STR0065+(cAliasSF3)->F3_NFISCAL+STR0066+(cAliasSF3)->F3_SERIE+"...") //"Procesando Factura: "#" Serie: "
			GeraDadCom(F3_NFISCAL,F3_SERIE,F3_CLIEFOR,F3_LOJA,F3_ENTRADA,F3_DTCANC,@aDArq,F3_TES) 
			DbSelectArea(cAliasSF3)
			dbSkip()
		Enddo
	Endif
Endif

//EMITIDAS - VENDAS
If lEmitidas .Or. lVendas
	DbSelectArea(cAliasTmp)
	DbCloseArea()

Endif
//COMPRAS
If lCompras
	DbSelectArea(cAliasCom)
	DbCloseArea()
Endif

If lEmitidas .Or. lVendas .Or. lCompras
	If oTmpTable <> Nil  
		oTmpTable:Delete()
		oTmpTable := Nil  
	EndIf
Endif

cFilAnt:= cResFilA
//Funcao que gera a linha de resumo nos que exijam esse detalhe e tambem
//realiza o fechamento de todos o .TXT...
GrvResTxt(aDArq)

//Restaura o indice original do arquivo SF3...
RestArea(aAreaSF3)

//Retorna a area original...
RestArea(aAreaAtu)

Return aDarq

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ GeraDadFEmi  ³Autor ³ Julio Cesar          ³Data³ 13/05/03 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Gera os arquivos que contem os dados referentes as         ³±± 
±±³          ³ Facturas Emitidas e Otras Percepciones.                    ³±± 
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function GeraDadFEmi(cNota,cSerie,cCliFor,cLoja,dDtaEmis,dDtaCanc,aDArq,cTES)

Local aAreaSF   := {}
Local aAreaSD   := {}
Local aAreaAtu  := GetArea()
Local aCab      := {}        //Array com os dados referentes as vendas (cabecalho)   
Local aLin      := {}        //Array com os dados referentes as vendas (linhas)   
Local aLinhas   := {}
Local aImps     := {}        
Local aAliq     := {}
Local aTES      := {}
Local cStr      := ""
Local cAliasSF  := Iif(cTES > "500","SF2","SF1")     
Local cAliasSD  := Iif(cTES > "500","SD2","SD1")     
LocaL cAliasCF  := Iif(F3_TIPOMOV == "V","SA1","SA2")     
Local nTotIsen  := 0
Local nTotNAlc  := 0
Local lIsento   := .F.
Local lNAlcIVA  := .F.
Local lNotaOk   := .F.
//Campos dos arquivos SF?
Local nSFFil    := (cAliasSF)->(FieldPos(SubStr(cAliasSF,2,2)+"_FILIAL"))
Local nSFDoc    := (cAliasSF)->(FieldPos(SubStr(cAliasSF,2,2)+"_DOC"))
Local nSFSer    := (cAliasSF)->(FieldPos(SubStr(cAliasSF,2,2)+"_SERIE"))
Local nSFCliFor := (cAliasSF)->(FieldPos(SubStr(cAliasSF,2,2)+Iif(cAliasSF == "SF2","_CLIENTE","_FORNECE")))
Local nSFLoja   := (cAliasSF)->(FieldPos(SubStr(cAliasSF,2,2)+"_LOJA"))
Local nSFEcf    := (cAliasSF)->(FieldPos(SubStr(cAliasSF,2,2)+"_ECF"))
Local nSFDtaEmis:= (cAliasSF)->(FieldPos(SubStr(cAliasSF,2,2)+"_EMISSAO"))
Local nSFDtaDgt := (cAliasSF)->(FieldPos(SubStr(cAliasSF,2,2)+"_DTDIGIT")) 
Local nSFVBrut  := (cAliasSF)->(FieldPos(SubStr(cAliasSF,2,2)+"_VALBRUT"))
Local nSFVMerc  := (cAliasSF)->(FieldPos(SubStr(cAliasSF,2,2)+"_VALMERC"))
Local nSFMoeda  := (cAliasSF)->(FieldPos(SubStr(cAliasSF,2,2)+"_MOEDA"))
Local nSFTxMoeda:= (cAliasSF)->(FieldPos(SubStr(cAliasSF,2,2)+"_TXMOEDA"))
Local nSFEsp    := (cAliasSF)->(FieldPos(SubStr(cAliasSF,2,2)+"_ESPECIE")) 
Local nSFTipo   := (cAliasSF)->(FieldPos(SubStr(cAliasSF,2,2)+"_TIPO"))
//Campos dos arquivos SD?
Local nSDDoc    := (cAliasSD)->(FieldPos(SubStr(cAliasSD,2,2)+"_DOC"))
Local nSDSer    := (cAliasSD)->(FieldPos(SubStr(cAliasSD,2,2)+"_SERIE"))
Local nSDCliFor := (cAliasSD)->(FieldPos(SubStr(cAliasSD,2,2)+Iif(cAliasSD == "SD2","_CLIENTE","_FORNECE")))
Local nSDLoja   := (cAliasSD)->(FieldPos(SubStr(cAliasSD,2,2)+"_LOJA"))
Local nSDEsp    := (cAliasSD)->(FieldPos(SubStr(cAliasSD,2,2)+"_ESPECIE"))
Local nSDEmis   := (cAliasSD)->(FieldPos(SubStr(cAliasSD,2,2)+"_EMISSAO"))
Local nSDQtde   := (cAliasSD)->(FieldPos(SubStr(cAliasSD,2,2)+"_QUANT"))
Local nSDUm     := (cAliasSD)->(FieldPos(SubStr(cAliasSD,2,2)+"_UM"))
Local nSDPrUnit := (cAliasSD)->(FieldPos(SubStr(cAliasSD,2,2)+Iif(cAliasSD == "SD2","_PRCVEN","_VUNIT")))
Local nSDDesc   := (cAliasSD)->(FieldPos(SubStr(cAliasSD,2,2)+Iif(cAliasSD == "SD2","_DESCON","_VALDESC")))
Local nSDTotal  := (cAliasSD)->(FieldPos(SubStr(cAliasSD,2,2)+"_TOTAL"))
Local nSDTes    := (cAliasSD)->(FieldPos(SubStr(cAliasSD,2,2)+"_TES"))
Local nI := 0
Local nX := 0
Local nRegSF := 0
     
// Moeda e Taxa para a factura/nota corrente.
Private nMoedaCor := 0
Private nTaxaMoeda:= 0
Private dDtaDgt 

// Caso o campo de Data da digitacao nao exista considera a data de emissao.
If nSFDtaDgt == 0
	nSFDtaDgt := nSFDtaEmis
EndIf
//Eh necessario fazer isso para que os dados das facturas ou notas canceladas
//sejam considerados nos arquivos...
If !Empty(dDtaCanc)
	SET DELETED OFF
EndIf

dbSelectArea(cAliasSF)
aAreaSF := GetArea()
dbSetOrder(1)
If dbSeek(xFilial(cAliasSF)+cNota+cSerie+cCliFor+cLoja)	
	If AllTrim(FieldGet(nSFEsp)) <> AllTrim((cAliasSF3)->F3_ESPECIE)
		nRegSF:=Recno()
		While !Eof() .And. xFilial(cAliasSF)+cNota+cSerie+cCliFor+cLoja ==;
			  FieldGet(nSFFil)+FieldGet(nSFDoc)+FieldGet(nSFSer)+FieldGet(nSFCliFor)+FieldGet(nSFLoja)
			  
			If AllTrim(FieldGet(nSFEsp)) <> AllTrim((cAliasSF3)->F3_ESPECIE)
				dbSkip()
			Else
				lNotaOk := .T.
				Exit
			EndIf
		End
	Else
		lNotaOk := .T.
	EndIf
	
	If !lNotaOk
		//A factura nao foi encontrada no arquivo SF? correspondente...
		VerifErro(,@aDArq,"5",cNota,cSerie,cCliFor,cLoja,,(cAliasSF3)->F3_ESPECIE,cAliasSF) 

		//Ativa o SET para nao visualizar mais a facturas ou notas canceladas...
		If !Empty(dDtaCanc)
			SET DELETED ON
		EndIf
		//Retorna as areas originais...
        DbGoto(nRegSF)
		//RestArea(aAreaSF)
		//RestArea(aAreaAtu)
	EndIf

	// Armazena a moeda e a respectiva taxa...	
	nMoedaCor  := FieldGet(nSFMoeda)	
	nTaxaMoeda := FieldGet(nSFTxMoeda)
	dDtaDgt    := FieldGet(nSFDtaDgt)	
	If aDArq[FAC_EMICAB][3][04][01] == Nil
		aDArq[FAC_EMICAB][3][01][01] := "2"
		aDArq[FAC_EMICAB][3][02][01] := SubStr(cData,1,6)
		aDArq[FAC_EMICAB][3][03][01] := Space(13)
		aDArq[FAC_EMICAB][3][04][02] := 0	//Total de linhas do tipo 1	
		aDArq[FAC_EMICAB][3][05][01] := Space(17) 
		aDArq[FAC_EMICAB][3][06][01] := SubStr(SM0->M0_CGC,1,11)
		aDArq[FAC_EMICAB][3][07][01] := Space(22)  
		aDArq[FAC_EMICAB][3][08][02] := 0	//Soma do campo 12
		aDArq[FAC_EMICAB][3][09][02] := 0	//Soma do campo 13
		aDArq[FAC_EMICAB][3][10][02] := 0	//Soma do campo 14
		aDArq[FAC_EMICAB][3][11][02] := 0	//Soma do campo 15
		aDArq[FAC_EMICAB][3][12][02] := 0	//Soma do campo 16
		aDArq[FAC_EMICAB][3][13][02] := 0	//Soma do campo 17
		aDArq[FAC_EMICAB][3][14][02] := 0	//Soma do campo 18
		aDArq[FAC_EMICAB][3][15][02] := 0	//Soma do campo 19
		aDArq[FAC_EMICAB][3][16][02] := 0	//Soma do campo 20
		aDArq[FAC_EMICAB][3][17][02] := 0	//Soma do campo 21
		aDArq[FAC_EMICAB][3][18][01] := Space(62)
	EndIf		
	
	aAreaSD := (cAliasSD)->(GetArea())
	If cAliasSD == "SD2"
		(cAliasSD)->(dbSetOrder(3))
    Else
   		(cAliasSD)->(dbSetOrder(1))
    EndIf

    //Nao foi encontrado o registro no arquivo SD? correspondente..
	If !(cAliasSD)->(dbSeek(xFilial(cAliasSD)+(cAliasSF)->(FieldGet(nSFDoc))+(cAliasSF)->(FieldGet(nSFSer))+(cAliasSF)->(FieldGet(nSFCliFor))+(cAliasSF)->(FieldGet(nSFLoja))))
    	VerifErro(,@aDArq,"6",cNota,cSerie,cCliFor,cLoja,,(cAliasSF3)->F3_ESPECIE,cAliasSD)
    EndIf            

	While !(cAliasSD)->(Eof()) .And.	xFilial(cAliasSD)+(cAliasSD)->(FieldGet(nSDDoc))+(cAliasSD)->(FieldGet(nSDSer))+(cAliasSD)->(FieldGet(nSDCliFor))+(cAliasSD)->(FieldGet(nSDLoja)) == ;
  									   	xFilial(cAliasSD)+FieldGet(nSFDoc)+FieldGet(nSFSer)+FieldGet(nSFCliFor)+FieldGet(nSFLoja) 

		If AllTrim(FieldGet(nSFEsp)) <> AllTrim((cAliasSD)->(FieldGet(nSDEsp)))
			(cAliasSD)->(dbSkip())
			Loop
		EndIf

		AAdd(aLin,M991TpComp(cAliasSD,(cAliasSD)->(FieldGet(nSDSer)),(cAliasSD)->(FieldGet(nSDEsp))))	//Campo 01 - Tipo de comprovante			
		//Campo 02 - Controlador Fiscal
		If cAliasSF == "SF2"
			AAdd(aLin,Iif((cAliasSF)->F2_ECF<>"1",Space(01),"C"))
		Else
			AAdd(aLin,Iif((cAliasSF)->F1_ECF<>"1",Space(01),"C"))
		EndIf
		AAdd(aLin,Dtos((cAliasSD)->(FieldGet(nSDEmis))))			//Campo 03 - Data do comprovante
		AAdd(aLin,PadL(AllTrim(SubStr((cAliasSD)->(FieldGet(nSDDoc)),1,4)),4,"0"))		//Campo 04 - Ponto de Venda		
		AAdd(aLin,PadL(AllTrim(SubStr((cAliasSD)->(FieldGet(nSDDoc)),5,8)),8,"0"))  		//Campo 05 - Numero do comprovante			
		AAdd(aLin,PadL(AllTrim(SubStr((cAliasSD)->(FieldGet(nSDDoc)),5,8)),8,"0"))  		//Campo 06 - Numero do comprovante registrado
		AAdd(aLin,MontaValor((cAliasSD)->(FieldGet(nSDQtde)),"@E 9999999.99999",12))		//Campo 07 - Quantidade
		AAdd(aLin,PesqUnMed((cAliasSD)->(FieldGet(nSDUm))))								//Campo 08 - Unidade de Medida
		AAdd(aLin,MontaValor((cAliasSD)->(FieldGet(nSDPrUnit)),"@E 9999999999999.999",16))	//Campo 09 - Preco Unitario
		AAdd(aLin,MontaValor((cAliasSD)->(FieldGet(nSDDesc)),"@E 9999999999999.99",15))	//Campo 10 - Valor de Bonificacao 
		AAdd(aLin,MontaValor(0,"@E 9999999999999.999",16))									//Campo 11 - Valor de Ajuste
		AAdd(aLin,MontaValor((cAliasSD)->(FieldGet(nSDTotal)),"@E 9999999999999.999",16))	//Campo 12 - SubTotal por registro
		AAdd(aLin,PesqInfImp(cAliasSD,IVA,"3",(cAliasSD)->(FieldGet(nSDTes)))[1])			//Campo 13 - Aliquota de IVA
//		AAdd(aLin,IndExGrv(DesTrans(aLin[13],2),@nTotIsen,@nTotNAlc,cAliasSD,@lNAlcIVA))	//Campo 14 - Indicacao de Isento ou Gravado
		AAdd(aLin,Iif(!Empty(dDtaCanc)," ",IndExGrv(DesTrans(aLin[13],2),@nTotIsen,@nTotNAlc,cAliasSD,@lNAlcIVA)))	//Campo 14 - Indicacao de Isento ou Gravado
		AAdd(aLin,Iif(Empty(dDtaCanc),Space(01),"A"))	//Campo 15 - Indicacao de Anulacao
		AAdd(aLin,CgfDesLivr(dDtaCanc,cAliasSD))		//Campo 16 - Livre - Acredito que seja util criar um PE...
	
		//Variavel que controla se a venda eh TOTALMENTE isenta de IVA
		If aLin[14] == "E"
			lIsento := .T.
		EndIf
				
		//Acumula os TES caso seja necessario gerar o arquivo OTRAS_PERCEP
		If aScan(aTES,{|x| x == (cAliasSD)->(FieldGet(nSDTes))}) == 0
			AAdd(aTES,(cAliasSD)->(FieldGet(nSDTes)))
		EndIf

		//Gera array com o total de cada imposto...
		AAdd(aImps,aClone(aDImps))

		//Armazena linhas para posterior Gravacao...
		AAdd(aLinhas,aClone(aLin))

		//Verifica se foi dado desconto para o item. Caso tenha eh necessario gerar
		//o registro de bonificacao...		
		/*
		Falei com o Bruno em 09/06/2003 e verificamos que hj nao ha como controlar somente 
		o desconto atribuido ao total da factura. Sendo assim vamos considerar que o 
		sistema so trabalha com desconto por item.
		If Val(aLin[10]) <> 0
			aLin[08] := "99"                     
			aLin[11] := aLin[10] 
			aLin[15] := "BONIFICACION"+Space(188)	
			AAdd(aLinhas,aClone(aLin))
		Endif 
		*/		
 		(cAliasSD)->(dbSkip())
		aLin := {}
 	End
    
	//Valorizar array com os dados que irao compor a linha para gravacao do arquivo 
	//de cabecalho...
	AAdd(aCab,"1")                      	//Campo 01 - Tipo de Registro
	AAdd(aCab,Dtos(FieldGet(nSFDtaEmis)))	//Campo 02 - Data do comprovante
	AAdd(aCab,M991TpComp(cAliasSF,FieldGet(nSFSer),FieldGet(nSFEsp)))	//Campo 03 - Tipo de comprovante
	//Campo 04 - Controlador Fiscal		
	If cAliasSF == "SF2"
		AAdd(aCab,Iif(F2_ECF<>"1",Space(01),"C"))
	Else
		AAdd(aCab,Iif(F1_ECF<>"1",Space(01),"C"))
 	EndIf
	AAdd(aCab,PadL(AllTrim(SubStr(FieldGet(nSFDoc),1,4)),4,"0"))	//Campo 05 - Ponto de Venda
	AAdd(aCab,PadL(AllTrim(SubStr(FieldGet(nSFDoc),5,8)),8,"0"))	//Campo 06 - Numero do comprovante			
	AAdd(aCab,PadL(AllTrim(SubStr(FieldGet(nSFDoc),5,8)),8,"0"))	//Campo 07 - Numero do comprovante registrado									
	AAdd(aCab,PQtdeFol(cAliasSF)) 				//Campo 08 - Quantidade de paginas								
	AAdd(aCab,PesqIdCliFor(cAliasCF,"1",FieldGet(nSFVBrut)))	//Campo 09 - Codigo de documento identificador do comprador
	AAdd(aCab,PesqIdCliFor(cAliasCF,"2",FieldGet(nSFVBrut)))	//Campo 10 - Numero de identificacao do comprador
	AAdd(aCab,PesqIdCliFor(cAliasCF,"4",FieldGet(nSFVBrut)))	//Campo 11 - Nome e sobrenome do comprador ou denominacao do comprador
	//O conteudo existente no intervalo entre os campos 12 a 21 sera
	//totalizado posteriomente.
	AAdd(aCab,FieldGet(nSFVBrut))			//Campo 12 - Valor total da transacao (Totaliza no Campo 08 do Arq. de Detalhe)
	AAdd(aCab,nTotNAlc)						//Campo 13 - Valor total que nao teve incidencia de IVA (Totaliza no Campo 09 do Arq. de Detalhe)
	AAdd(aCab,TotCat(IVA,"1",aImps,"2"))	//Campo 14 - Importe Neto Gravado (Totaliza no Campo 10 do Arq. de Detalhe)
	AAdd(aCab,TotCat(IVA,"2",aImps,"2")) 	//Campo 15 - Imposto Liquidado (Totaliza no Campo 11 do Arq. de Detalhe)
	AAdd(aCab,TotCat(RNI,"2",aImps,"2"))	//Campo 16 - Imposto Liquidado a RNI (Totaliza no Campo 12 do Arq. de Detalhe)
	AAdd(aCab,nTotIsen)						//Campo 17 - Importe de operacoes Isentas (Totaliza no Campo 13 do Arq. de Detalhe)
	AAdd(aCab,TotCat(PIN,"2",aImps,"2"))	//Campo 18 - Importe de percepciones ou pagos a conta sobre impostos nacionais (Totaliza no Campo 14 do Arq. de Detalhe)
	AAdd(aCab,TotCat(PIB,"2",aImps,"2"))	//Campo 19 - Importe de percepciones de ingresos brutos (Totaliza no Campo 15 do Arq. de Detalhe)
	AAdd(aCab,TotCat(PIM,"2",aImps,"2"))	//Campo 20 - Importe de percepciones de impostos municipais (Totaliza no Campo 16 do Arq. de Detalhe)
	AAdd(aCab,TotCat(PII,"2",aImps,"2"))	//Campo 21 - Importe de impostos internos (Totaliza no Campo 17 do Arq. de Detalhe)
    //
	AAdd(aCab,Replicate("0",15))			//Campo 22 - Transporte
	AAdd(aCab,PesqIdCliFor(cAliasCF,"3"))	//Campo 23 - Tipo de responsavel
	AAdd(aCab,PMoeda(FieldGet(nSFMoeda)))	//Campo 24 - Codigo da moeda
	AAdd(aCab,MontaValor(FieldGet(nSFTxMoeda),"@E 9999.999999",10))	//Campo 25 - Taxa da moeda
	AAdd(aCab,TotCat(IVA,"3",aImps,"1",,@aAliq)) 						//Campo 26 - Quantidade de aliquotas de IVA
	AAdd(aCab,PesqCodOp(aCab[13],aCab[15],FieldGet(nSFCliFor),FieldGet(nSFLoja),cAliasCF,"1",lNAlcIVA))	//Campo 27 - Codigo da operacao
	AAdd(aCab,PesqCAI(cAliasSF,"1"))	//Campo 28 - CAI
	AAdd(aCab,PesqCAI(cAliasSF,"2"))	//Campo 29 - Data de vencimento
	AAdd(aCab,Iif(Empty(dDtaCanc),Replicate("0",8),Dtos(dDtaCanc)))	//Campo 30 - Data de Anulacao do comprovante

	//Executa funcao que verifica possiveis erros na geracao dos dados...
	VerifErro(aCab,@aDArq,"1",FieldGet(nSFDoc),FieldGet(nSFSer),FieldGet(nSFCliFor),; 
	          FieldGet(nSFLoja),lIsento,FieldGet(nSFEsp),cAliasSF,.T.,;
	          Iif(PesqIdCliFor(cAliasCF,"5")=="1",.T.,.F.))

	//Totaliza a quantidade de linhas do tipo 1		
	aDArq[FAC_EMICAB][03][04][2] += 1
	
	For nX := 12 To 21
		If Empty(dDtaCanc)
  			//Calcula os totais gerais...
			aDArq[FAC_EMICAB][03][nX-4][02] += (aCab[nX] * Iif(aCab[3]$"03|08|13|21|38|85",-1,1))
		Endif
		//Formata os dados para a gravacao do arquivo texto
		aCab[nX] := MontaValor(aCab[nX],"@E 9999999999999.99",15)
	Next nX
	                     
	//Gera Linha que sera gravada no arquivo de cabecalho 
	aEval(aCab,{|x| cStr += x})
	cStr += Chr(13)+Chr(10)
		
	//Grava linha no arquivo...
	TrabArqTxt(.F.,@aDArq,FAC_EMICAB,aDArq[FAC_EMICAB][1],aDArq[FAC_EMICAB][2],cStr)	

	//Gera Linha que sera gravada no arquivo de itens... 
	For nI := 1 To Len(aLinhas)
		cStr := ""              
		aEval(aLinhas[nI],{|x| cStr += x})                
		cStr += Chr(13)+Chr(10)
		
		//Grava linha no arquivo no arquivo de itens...
		TrabArqTxt(.F.,@aDArq,FAC_EMIDET,aDArq[FAC_EMIDET][1],aDArq[FAC_EMIDET][2],cStr)	
    Next nI           
		
	//Quando o valor dos Ingressos Brutos eh maior que zero eh necessario
	//gerar o arquivo OTRAS_PERCEP, com os dados referentes aos impostos 
	//de PIB.
	If Val(aCab[19]) <> 0 .Or. Val(aCab[20]) <> 0
		GeraOtrPercep(aDArq,aCab,aTES,aImps,cAliasSF)
	EndIf

	//Trata os dados que serao gravados no arquivo texto
	aDArq[FAC_EMICAB][03][04][01] := MontaValor(aDArq[FAC_EMICAB][3][04][2],"99999999",08)
	For nI := 08 To 17
		aDArq[FAC_EMICAB][03][nI][01] := MontaValor(aDArq[FAC_EMICAB][03][nI][02],"@E 9999999999999.99",15)
	Next

	//Limpa o array que possui o total dos impostos...
	aImps := {}

	//Retorna a area original do arquivo SD...
	RestArea(aAreaSD)
Else
	//A factura nao foi encontrada no arquivo SF? correspondente...
	VerifErro(,@aDArq,"5",cNota,cSerie,cCliFor,cLoja,,(cAliasSF3)->F3_ESPECIE,cAliasSF)
EndIf

//Ativa o SET para nao visualizar mais a facturas ou notas canceladas...
If !Empty(dDtaCanc)
	SET DELETED ON
EndIf

//Retorna as areas originais...
RestArea(aAreaSF)
RestArea(aAreaAtu)

Return Nil 

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ M991TpComp    ³Autor ³ Julio Cesar          ³Data³ 13/05/03 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Retorna o codigo do tipo de comprovante, com base na serie ³±± 
±±³          ³ informada.                                                 ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function M991TpComp(cAlias,cSerie,cEspecie,cArquivo)                                           

Local cCodTipo := ""     
Default cArquivo := " "   

cEspecie := GetSesNew(AllTrim(cEspecie),Iif(cAlias$"SD2|SF2","1","2"))

If cAlias == "SF1"
	If !Empty(SF1->F1_HAWB)
		Do Case   //Alteracoes referentes aos BOPS 109531
			Case SF1->F1_TIPO_NF == "9"
				cCodTipo := "14" //Documento Aduanero
			Case SF1->F1_TIPO_NF == "5"
				cCodTipo := "87" //	Otros comprobantes - servicios del exterior
		EndCase
	EndIf
EndIf

If Empty(cCodTipo)
	Do Case
		Case Substr(cSerie,1,1) == "A" .And. "NF"$cEspecie 
			cCodTipo := "01"
		Case Substr(cSerie,1,1) == "A" .And. "ND"$cEspecie .and.  UPPER(cArquivo) <> "CV3865"
			cCodTipo := "02"    
		Case Substr(cSerie,1,1) == "A" .And. "NDP"$cEspecie .and.  UPPER(cArquivo) == "CV3865"
			cCodTipo := "02"
		Case Substr(cSerie,1,1) == "A" .And. "NDI"$cEspecie .and.  UPPER(cArquivo) == "CV3865"
			cCodTipo := "03"		
		Case Substr(cSerie,1,1) == "A" .And. "NC"$cEspecie .and.  UPPER(cArquivo) <> "CV3865"
			cCodTipo := "03" 
		Case Substr(cSerie,1,1) == "A" .And. "NCP"$cEspecie .and.  UPPER(cArquivo) == "CV3865"
			cCodTipo := "03"
		Case Substr(cSerie,1,1) == "A" .And. "NCI"$cEspecie .and.  UPPER(cArquivo) == "CV3865"
			cCodTipo := "02"						
		Case Substr(cSerie,1,1) == "B" .And. "NF"$cEspecie
			cCodTipo := "06"
		Case Substr(cSerie,1,1) == "B" .And. "ND"$cEspecie  .and.  UPPER(cArquivo) <> "CV3865"
			cCodTipo := "07"
		Case Substr(cSerie,1,1) == "B" .And. "NDP"$cEspecie  .and.  UPPER(cArquivo) == "CV3865"
			cCodTipo := "07"
		Case Substr(cSerie,1,1) == "B" .And. "NDI"$cEspecie  .and.  UPPER(cArquivo) == "CV3865"
			cCodTipo := "08"
		Case Substr(cSerie,1,1) == "B" .And. "NC"$cEspecie .and.  UPPER(cArquivo) <> "CV3865"
			cCodTipo := "08"
		Case Substr(cSerie,1,1) == "B" .And. "NCP"$cEspecie .and.  UPPER(cArquivo) == "CV3865"
			cCodTipo := "08"
		Case Substr(cSerie,1,1) == "B" .And. "NCI"$cEspecie .and.  UPPER(cArquivo) == "CV3865"
			cCodTipo := "07"						
		Case Substr(cSerie,1,1) == "C" .And. "NF"$cEspecie
			cCodTipo := "11"
		Case Substr(cSerie,1,1) == "C" .And. "ND"$cEspecie .and.  UPPER(cArquivo) <> "CV3865"
			cCodTipo := "12"
		Case Substr(cSerie,1,1) == "C" .And. "NDP"$cEspecie .and.  UPPER(cArquivo) == "CV3865"
			cCodTipo := "12"
		Case Substr(cSerie,1,1) == "C" .And. "NC"$cEspecie .and.  UPPER(cArquivo) <> "CV3865"
			cCodTipo := "13"
		Case Substr(cSerie,1,1) == "C" .And. "NCP"$cEspecie .and.  UPPER(cArquivo) == "CV3865"
			cCodTipo := "13"
		Case Substr(cSerie,1,1) == "E" .And. "NF"$cEspecie
			cCodTipo := "19"
		Case Substr(cSerie,1,1) == "E" .And. "ND"$cEspecie .and.  UPPER(cArquivo) <> "CV3865"
			cCodTipo := "20"
		Case Substr(cSerie,1,1) == "E" .And. "NDP"$cEspecie .and.  UPPER(cArquivo) == "CV3865"
			cCodTipo := "20"
		Case Substr(cSerie,1,1) == "E" .And. "NDI"$cEspecie .and.  UPPER(cArquivo) == "CV3865"
			cCodTipo := "21"						
		Case Substr(cSerie,1,1) == "E" .And. "NC"$cEspecie .and.  UPPER(cArquivo) <> "CV3865"
			cCodTipo := "21"
		Case Substr(cSerie,1,1) == "E" .And. "NCP"$cEspecie .and.  UPPER(cArquivo) == "CV3865"
			cCodTipo := "21"
		Case Substr(cSerie,1,1) == "E" .And. "NCI"$cEspecie .and.  UPPER(cArquivo) == "CV3865"
			cCodTipo := "20"						
		Case Substr(cSerie,1,1) == "A" .And. "CF"$cEspecie
			cCodTipo := "34"
		Case Substr(cSerie,1,1) == "B" .And. "CF"$cEspecie
			cCodTipo := "35"
		Case Substr(cSerie,1,1) == "C" .And. "CF"$cEspecie
			cCodTipo := "36"
		Case Substr(cSerie,1,1) == "M" .And. "NF"$cEspecie
			cCodTipo := "51"
		Case Substr(cSerie,1,1) == "M" .And. "ND"$cEspecie 
			cCodTipo := "52"
		Case Substr(cSerie,1,1) == "M" .And. "NC"$cEspecie
			cCodTipo := "53"
		Case Substr(cSerie,1,1) == "A" .And. "NDC"$cEspecie .and.  UPPER(cArquivo) == "CV3865"
			cCodTipo := "02"			
		Case Substr(cSerie,1,1) == "B" .And. "NDC"$cEspecie .and.  UPPER(cArquivo) == "CV3865"
			cCodTipo := "07"			
		Case Substr(cSerie,1,1) == "C" .And. "NDC"$cEspecie .and.  UPPER(cArquivo) == "CV3865"
			cCodTipo := "20"									
		Case Substr(cSerie,1,1) == "A" .And. "NCC"$cEspecie .and.  UPPER(cArquivo) == "CV3865"
			cCodTipo := "03"			
		Case Substr(cSerie,1,1) == "B" .And. "NCC"$cEspecie .and.  UPPER(cArquivo) == "CV3865"
			cCodTipo := "08"			
		Case Substr(cSerie,1,1) == "C" .And. "NCC"$cEspecie .and.  UPPER(cArquivo) == "CV3865"
			cCodTipo := "21"												
		Case Substr(cSerie,1,1) == "A" .And. "NDE"$cEspecie .and.  UPPER(cArquivo) == "CV3865"
			cCodTipo := "03"			
		Case Substr(cSerie,1,1) == "B" .And. "NDE"$cEspecie .and.  UPPER(cArquivo) == "CV3865"
			cCodTipo := "08"			
		Case Substr(cSerie,1,1) == "C" .And. "NDE"$cEspecie .and.  UPPER(cArquivo) == "CV3865"
			cCodTipo := "13"									
		Case Substr(cSerie,1,1) == "A" .And. "NCE"$cEspecie .and.  UPPER(cArquivo) == "CV3865"
			cCodTipo := "02"			
		Case Substr(cSerie,1,1) == "B" .And. "NCE"$cEspecie .and.  UPPER(cArquivo) == "CV3865"
			cCodTipo := "07"			
		Case Substr(cSerie,1,1) == "C" .And. "NCE"$cEspecie .and.  UPPER(cArquivo) == "CV3865"
			cCodTipo := "12"												                                                               		
	EndCase
Endif
Return(cCodTipo)		

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ M991NrComp   ³Autor ³ Marcello             ³Data³06/10/2006³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Verifica se o codigo do comprovante possui letras, retornan³±± 
±±³          ³ zeros, dependendo do tipo de comprovante.                  ³±±
±±³          ³ Bops 109531                                                ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function M991NrComp(cDoc,cTpComp)
Return( IIf(Val(cDoc)==0 .And. cTpComp$"14,87",StrZero(0,12),cDoc) )

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ MT991SETpC   ³Autor ³ Adilson              ³Data³ 08/12/04 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Retorna a Serie e a Especie do tipo de comprovante.        ³±± 
±±³          ³                                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function MT991SETpC(cAlias,cCodTipo)

//Local cCodTipo := ""
Local cCpoSerie:= SubStr(cAlias,2,2)+"_SERIE" 
Local cSerie	:="", cEspecie:=""

cEspecie := GetSesNew(AllTrim(cEspecie),Iif(cAlias$"SD2|SF2","1","2"))

Do Case
	Case cCodTipo == "01" 
		cSerie    := "A"+Space(TamSX3(cCpoSerie)[1]-1)
		cEspecie  := MVNOTAFIS
	Case cCodTipo == "02"
		cSerie    := "A"+Space(TamSX3(cCpoSerie)[1]-1)
		cEspecie  := GetSesNew('NDP','2')
	Case cCodTipo == "03"		                
		cSerie    := "A"+Space(TamSX3(cCpoSerie)[1]-1)
		cEspecie  := GetSesNew('NCP','2')
	Case cCodTipo == "06"                       
		cSerie    := "B"+Space(TamSX3(cCpoSerie)[1]-1)
		cEspecie  := MVNOTAFIS
	Case cCodTipo == "07"                       
		cSerie    := "B"+Space(TamSX3(cCpoSerie)[1]-1)
		cEspecie  := GetSesNew('NDP','2')
	Case cCodTipo == "08"		                                              
		cSerie    := "B"+Space(TamSX3(cCpoSerie)[1]-1) 
		cEspecie  := GetSesNew('NCP','2')
	Case cCodTipo == "11"                        
		cSerie    := "C"+Space(TamSX3(cCpoSerie)[1]-1)
		cEspecie  := MVNOTAFIS
	Case cCodTipo == "12"                       
		cSerie    := "C"+Space(TamSX3(cCpoSerie)[1]-1)
		cEspecie  := GetSesNew('NDP','2')
	Case cCodTipo == "13"		                                              
		cSerie    := "C"+Space(TamSX3(cCpoSerie)[1]-1)
		cEspecie  := GetSesNew('NCP','2')
	Case cCodTipo == "19"                        		 
		cSerie    := "E"+Space(TamSX3(cCpoSerie)[1]-1)
		cEspecie  := MVNOTAFIS
	Case cCodTipo == "20"                       
		cSerie    := "E"+Space(TamSX3(cCpoSerie)[1]-1)
		cEspecie  := GetSesNew('NDP','2')
	Case cCodTipo == "21"		                				                               
		cSerie    := "E"+Space(TamSX3(cCpoSerie)[1]-1)
		cEspecie  := GetSesNew('NCP','2')
	Case cCodTipo == "34"
		cSerie    := "A"+Space(TamSX3(cCpoSerie)[1]-1)
		cEspecie  := "CF"
	Case cCodTipo == "35"
		cSerie    := "B"+Space(TamSX3(cCpoSerie)[1]-1)
		cEspecie  := "CF"
	Case cCodTipo == "36"                       
		cSerie    := "C"+Space(TamSX3(cCpoSerie)[1]-1)
		cEspecie  := "CF"
	Otherwise
		cSerie    := ""
		cEspecie  := ""
EndCase

/*If Empty(cCodTipo) .And. cAlias == "SF1"
	If !Empty(SF1->F1_HAWB)
		cCodTipo := "14" //Documento Aduanero
	EndIf
EndIf*/

Return({cSerie,cEspecie})

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ MontaValor   ³Autor ³ Julio Cesar          ³Data³ 13/05/03 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Converte o valor passado para a string que sera gravada    ³±± 
±±³          ³ no arquivo texto.                                          ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function MontaValor(nValor,cPicture,nTam,lConverte)

Local cValAux := ""
Local nPos    := 0
Local lRotinaOk := .F.                                   
Local nDecimais := MsDecimais(1)
Default lConverte := .T.

// Verifica se eh necessario realizar a conversao do valor
If lConverte .And. (nMoedaCor <> 1) .And. (nTam >= 15) .And. (nValor <> 0)

	// Verifica se a rotina foi chamada da geracao dos dados de compras ou vendas.
	// Conforme a resolucao para as faturas emitidas o valor devera permanecer na
	// moeda da operacao.
	lRotinaOk := AtIsRotina("GERADADVEV")
	If !lRotinaOk 
		lRotinaOk := AtIsRotina("GERADADCOM")
	EndIf
  
	If !lRotinaOk 
		lRotinaOk := AtIsRotina("NFEARG")
 	EndIf   
 	
	// Converte o valor para a moeda 1
	If lRotinaOk
		nValor := Round(xMoeda(nValor,nMoedaCor,1,dDtaDgt,nDecimais+1,nTaxaMoeda),nDecimais)
	EndIf
EndIf

cValAux  := Transform(nValor,cPicture)
nPos     := At(",",cValAux)
If nPos > 0
	cValAux  := SubStr(cValAux,1,nPos-1)+SubStr(cValAux,nPos+1,Len(cValAux))
	cValAux  := Replicate("0",nTam-Len(AllTrim(cValAux)))+AllTrim(cValAux)
Else
	cValAux  := Replicate("0",nTam-Len(AllTrim(cValAux)))+AllTrim(cValAux)
EndIf

Return(cValAux)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ PesqUnMed    ³Autor ³ Julio Cesar          ³Data³ 13/05/03 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Pesquisa no arquivo SX5 a unidade de medida do produto e   ³±± 
±±³          ³ e retorna o codigo correspondente para a geracao do arquivo³±± 
±±³          ³ texto.                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function PesqUnMed(cUM)                                              

Local cCodUM   := ""
Local aAreaSX5 := {}
Local aAreaAtu := GetArea()

cUM := cUM+Space(TAMSX3("X5_CHAVE")[01]-Len(AllTrim(cUM)))

dbSelectArea("SX5")
aAreaSX5 := GetArea()
dbSetOrder(1)
If dbSeek(xFilial("SX5")+"OA"+cUM)
	cCodUM := SubStr(X5DESCRI(),1,2)
Else
	cCodUM := "98" //Outras Unidades
EndIf
RestArea(aAreaSX5)
RestArea(aAreaAtu)

Return(cCodUM)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ PesqAliqImp  ³Autor ³ Julio Cesar          ³Data³ 13/05/03 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Com base no TES pesquisa o imposto e retorna o valor da    ³±± 
±±³          ³ aliquota.                                                  ³±± 
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function PesqInfImp(cAlias,nCatImp,cInf,cTES,cTpRet)

//cAlias := De que arquivo serao extraidas as informacoes
//nCatImp:= Para que categoria de imposto se deseja obter a informacao (IVA,RNI,PIB)
//cInf   := Qual a informacao desejada (1-Base, 2-Valor, 3-Aliquota)
//cTES   := TES para que seja verificado todos os impostos amarrados ao mesmo
//cTpRet => 1-String/2-Numerico                           

Local aImpInf  := TesImpInf(cTES)
Local nI       := 0
Local nX       := 0
Local nY       := 0
Local cCpoAux  := ""
Local uRet     

Default cTpRet := "1"

//Reinicializa array...
aEval(aDImps,{|x,y| aDImps[y][3]:={} })

For nI := 1 To Len(aImpInf)      
	nX := aScan(aDImps,{|x| AllTrim(aImpInf[nI][1])$AllTrim(x[2])})
	
	If nX > 0
		nY := aScan(aDImps[nX][3],{|x| x[5] == aImpInf[nI][09]})
		
		If nY == 0                                
			//Cria posicao no array...
			AAdd(aDImps[nX][3],Array(06))
			 
			//Determina posicao a ser valorizada...
			nY := Len(aDImps[nX][03])  
			
			//Inicializa posicao do array...
			aDImps[nX][03][nY][01] := 0              
			aDImps[nX][03][nY][03] := 0
		EndIf
						        
		//Armazena o valor da base
		cCpoAux := SubStr(cAlias,2,2)+SubStr(aImpInf[nI][7],3,8)
		aDImps[nX][03][nY][01] := (cAlias)->&cCpoAux
		aDImps[nX][03][nY][02] := MontaValor(aDImps[nX][03][nY][01],"@E 9999999999999.99",15)
				
		//Armazena o valor do imposto
		cCpoAux := SubStr(cAlias,2,2)+SubStr(aImpInf[nI][2],3,8)		
		aDImps[nX][03][nY][03] += (cAlias)->&cCpoAux  
		aDImps[nX][03][nY][04] := MontaValor(aDImps[nX][03][nY][03],"@E 9999999999999.99",15)
			                                 
		//Armazena a aliquota do imposto
		//Caso o valor da base e do imposto sejam iguais a zero eh determinado
		//que o valor da aliquota tambem e zero. Por algum motivo esse item se
		//eh isento do calculo do IVA...
		If (nX == IVA) .And. (aDImps[nX][03][nY][01] == 0) .And. (aDImps[nX][03][nY][03] == 0)
			aDImps[nX][03][nY][05] := 0
		Else
			aDImps[nX][03][nY][05] := aImpInf[nI][09]
		EndIf
		aDImps[nX][03][nY][06] := MontaValor(aDImps[nX][03][nY][05],"@E 99.99",4)
	EndIf
Next nI

//Verifica se o item nao sofreu incidendencia de IVA. Caso nao tenha sofrido
//eh necessario incluir a aliquota de IVA igual a 0%
If Empty(aDImps[IVA][3])
	//Cria posicao no array...
	AAdd(aDImps[IVA][3],Array(06))
			 
	//Determina posicao a ser valorizada...
	nY := Len(aDImps[IVA][03])  
	
	//Inicializa posicao do array...
	aDImps[IVA][03][nY][01] := IIF(aDImps[IVA][03][nY][01]== Nil,0,aDImps[IVA][03][nY][01])
	aDImps[IVA][03][nY][02] := MontaValor(aDImps[IVA][03][nY][01],"@E 9999999999999.99",15)
	aDImps[IVA][03][nY][03] := aDImps[IVA][03][nY][01]
	aDImps[IVA][03][nY][04] := MontaValor(aDImps[IVA][03][nY][01],"@E 9999999999999.99",15)
	aDImps[IVA][03][nY][05] := aDImps[IVA][03][nY][05]
	aDImps[IVA][03][nY][06] := MontaValor(aDImps[IVA][03][nY][05],"@E 99.99",4)
EndIf

Do Case
	Case cInf == "1"
		uRet := Iif(cTpRet=="1",aDImps[nCatImp][3][1][2],aDImps[nCatImp][3][1][1]) 
	Case cInf == "2"
		uRet := Iif(cTpRet=="1",aDImps[nCatImp][3][1][4],aDImps[nCatImp][3][1][3])
	Case cInf == "3"
		uRet := {}
		For nI := 1 To Len(aDImps[nCatImp][3])
			AAdd(uRet,Iif(cTpRet=="1",aDImps[nCatImp][3][nI][6],aDImps[nCatImp][3][nI][5]))
		Next nI
EndCase	
 		
Return(uRet)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ IndExGrv     ³Autor ³ Julio Cesar          ³Data³ 13/05/03 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Determina se o produto sofreu uma isencao de IVA.          ³±± 
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function IndExGrv(nAliq,nTotIsen,nTotNAlc,cAlias,lNAlcIVA)

Local cIndExGrv := ""       
Local cCpoProd  := SubStr(cAlias,2,2)+"_COD"
Local cCpoVMerc := SubStr(cAlias,2,2)+"_TOTAL"
Local aAreaSB1  := {}
Local aAreaAtu  := GetArea()

If nAliq == 0
	cIndExGrv := "E"
	dbSelectArea("SB1")
	aAreaSB1 := GetArea()
	dbSetOrder(1)
	If dbSeek(xFilial("SB1")+(cAlias)->&cCpoProd.)
		If SB1->B1_NALCIVA == "1"
			nTotNAlc += (cAlias)->&cCpoVMerc.
			lNAlcIVA := .T.
		Else
			nTotIsen += (cAlias)->&cCpoVMerc.
		EndIf
	EndIf
	RestArea(aAreaSB1)
	RestArea(aAreaAtu)
Else
	cIndExGrv := "G"		
EndIf

Return(cIndExGrv)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ TrabArqTxt   ³Autor ³ Julio Cesar          ³Data³ 13/05/03 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Funcao que realiza as principais acoes com os arquivos .TXT³±±  
±±³          ³ (Criacao, inclusao de linhas e fechamento do arquivo)      ³±± 
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function TrabArqTxt(lFecha,aDArq,nI,cNomeArq,nHdl,cStr)
     
Local lRet := .T.

If !lFecha
	If nHdl == 0
		//Cria e abre o arquivo de cabecalho
		nHdl := FOpen(MV_PAR05+cNomeArq,2+64)
		If nHdl == -1
			nHdl := FCreate(MV_PAR05+cNomeArq)
			If nHdl == -1
				MsgAlert(STR0005+cNomeArq) //"Nao foi possivel criar o arquivo "
				lRet := .F.
			Else
				aDArq[nI][02] := nHdl
			EndIf
		Else
			aDArq[nI][02] := nHdl
			If MsgYesNo(STR0006+cNomeArq+STR0007) //"O arquivo "###" ja existe. Deseja continuar o processo e criar um novo arquivo?"
				FClose(nHdl)
				nHdl :=FErase(MV_PAR05+cNomeArq)
				If nHdl == -1
					MsgAlert(STR0008+cNomeArq) //"Nao foi possivel excluir o arquivo "
					lRet := .F.
				Else
					nHdl := FCreate(MV_PAR05+cNomeArq)
					If nHdl == -1
						MsgAlert(STR0005+cNomeArq) //"Nao foi possivel criar o arquivo "
						lRet := .F.
					Else
						aDArq[nI][02] := nHdl
					EndIf
				EndIf
			Else                    
				//Caso o usuario escolhar abortar a rotina todos os arquivos
				//abertos devem ser fechados...
				For nI := 1 To Len(aDArq)
					If aDArq[nI][02] <> Nil .And. aDArq[nI][02] <> 0
						nHdl := aDArq[nI][02]
						FClose(nHdl)
					EndIf
				Next nI
				lRet := .F.
			EndIf
		EndIf
	Else        
		FWrite(nHdl,cStr)
	EndIf
Else 
	FClose(nHdl)                
EndIf

Return(lRet)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ CriaArqTxt   ³Autor ³ Julio Cesar          ³Data³ 13/05/03 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Cria o array aDarq, que possue todas as informacoes dos    ³±±  
±±³          ³ arquivos .TXT e executa a funcao responsavel pela criacao  ³±±  
±±³          ³ ou abertura dos mesmos.                                    ³±± 
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function CriaArqTxt(aDArq)
Local nI := 0

If MV_PAR13 == 1 .Or. MV_PAR13 == 4
	//Arquivo de Facturas Emitidas - Cabecalho     
	aDArq[FAC_EMICAB][01] := "CABECERA_"+MV_PAR01+cMes+".TXT"
	aDArq[FAC_EMICAB][02] := 0 
	aDArq[FAC_EMICAB][03] := Array(18,2)
	//Arquivo de Facturas Emitidas - Detalhe
	aDArq[FAC_EMIDET][01] := "DETALLE_"+MV_PAR01+cMes+".txt"
	aDArq[FAC_EMIDET][02] := 0         
	aDArq[FAC_EMIDET][03] := Nil
	//Arquivo de "Otras Percepciones"
	aDArq[OTR_PERCEP][01] := "OTRAS_PERCEP_"+MV_PAR01+cMes+".txt"
	aDArq[OTR_PERCEP][02] := 0
	aDArq[OTR_PERCEP][03] := Nil 
EndIf

If MV_PAR13 = 2 .Or. MV_PAR13 = 4
	//Arquivo de Reg. de Vendas
	aDArq[REG_REGVEN][01] := "VENTAS_"+MV_PAR01+cMes+".txt"
	aDArq[REG_REGVEN][02] := 0
	aDArq[REG_REGVEN][03] := Array(19,2)
EndIf

If MV_PAR13 = 3 .Or. MV_PAR13 = 4
	//Arquivo de Reg. de Compras 
	aDArq[REG_REGCOM][01] := "COMPRAS_"+MV_PAR01+cMes+".txt"
	aDArq[REG_REGCOM][02] := 0       
	aDArq[REG_REGCOM][03] := Array(19,2)
EndIf

//Arquivo de "Log de Erros"
aDArq[LOG_ERROS][01] := "MATA991.LOG"
aDArq[LOG_ERROS][02] := 0
aDArq[LOG_ERROS][03] := Nil    

//Manipula arquivos .TXT
For nI := 1 To Len(aDArq)
	If aDArq[nI][01] <> Nil
		lRet := TrabArqTxt(.F.,@aDArq,nI,aDArq[nI][1],aDArq[nI][2])
		If !lRet
			Exit
		EndIf
	EndIf
Next nI

Return(lRet) 

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ GrvResTxt    ³Autor ³ Julio Cesar          ³Data³ 13/05/03 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Realiza a gravacao da linha de resumo, para os arquivos    ³±±  
±±³          ³ que exijam, e tambem realiza o fechamento de todos os      ³±±  
±±³          ³ arquivos .TXT                                              ³±± 
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function GrvResTxt(aDArq)

Local cStr := ""
Local nI   := 0
Local aDRes:= {}

For nI := 1 To Len(aDArq)
	//So realiza a gravacao caso o arquivo necessite de uma linha de resumo...
	If aDArq[nI][3] <> Nil .And. aDArq[nI][3][1][1] <> Nil
		aDRes := aClone(aDArq[nI][3])
		
		//Gera Linha que sera gravada no arquivo... 
		aEval(aDRes,{|x,y| cStr += aDRes[y][1]})
		cStr += Chr(13)+Chr(10)
		
		//Grava linha no arquivo... 
		TrabArqTxt(.F.,@aDArq,nI,aDArq[nI][1],aDArq[nI][2],cStr)	
		
		//Limpa variaveis para reutilizacao...
		cStr := ""
		aDRes:= {}
 	EndIf 
	//Fecha o arquivo .TXT 
	TrabArqTxt(.T.,,,,aDArq[nI][2])
Next nI

Return Nil

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ PMoeda       ³Autor ³ Julio Cesar          ³Data³ 13/05/03 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Pesquisa no arquivo SX5 a moeda usada na factura e retorna ³±± 
±±³          ³ o codigo correspondente para a geracao do arquivo texto.   ³±± 
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function PMoeda(nMoeda)

Local aAreaSX5 := {}
Local aAreaAtu := GetArea()
Local cCodMoeda:= ""

cCodMoeda := AllTrim(Str(nMoeda))
cCodMoeda := cCodMoeda+Space(TAMSX3("X5_CHAVE")[01]-Len(cCodMoeda))

dbSelectArea("SX5")
aAreaSX5 := GetArea()
dbSetOrder(1)
If dbSeek(xFilial("SX5")+"OB"+cCodMoeda)
	cCodMoeda := SubStr(X5DESCRI(),1,3)
Else
	cCodMoeda := ""
EndIf
RestArea(aAreaSX5)
RestArea(aAreaAtu)

Return(cCodMoeda)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ PesqIdCliFor ³Autor ³ Julio Cesar          ³Data³ 13/05/03 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Retorna o codigo do tipo de documento de identicacao       ³±± 
±±³          ³ utilizado pelo cliente/fornecedor.                         ³±± 
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function PesqIdCliFor(cAlias,cOpc,nValBrut,cIDAnt,lNum)

Local aAreaSX5 	:= {}     
Local aAreaSA  	:= {} 
Local aAreaAtu 	:= GetArea()
Local aAreaSLS 	:= SLS->(GetArea())
Local cIdCli   	:= "" 
Local cCpoCUIT 	:= ""
Local cCpoTipo 	:= ""
Local cCpoNome 	:= ""
Local cCpoRG1415 := ""
Local cCpoAFIP 	:= ""
Local cCopRG   	:= "" 
Local cCopEnd	:= "" 
Local cCopEst	:= ""
Local cCopCep	:= ""
Local cCopBai	:= ""

Default cIDAnt 	:= ""
Default lNum   	:= .F.	

If cOpc$"1|2|4|5|6|7|8|9"
	SLS->(dbSetOrder(1))
	If SLS->(dbSeek(xFilial("SLS")+(cAliasSF3)->F3_SERIE+(cAliasSF3)->F3_NFISCAL+(cAliasSF3)->F3_TIPO))
		Do Case
			Case cOpc == "1"
				cIdCli := AllTrim(SLS->LS_TPDOCCF)
				If cIdCli <> "6"
					cIdCli := cIdCli+Space(TAMSX3("X5_CHAVE")[01]-Len(cIdCli))
					dbSelectArea("SX5")
					aAreaSX5 := GetArea()
					dbSetOrder(1)
					If dbSeek(xFilial("SX5")+"OC"+cIdCli)
						cIdCli := SubStr(X5DESCRI(),1,2)
					EndIf
					RestArea(aAreaSX5)
				Else 
					cdIdCli := SLS->LS_TIPOCI
				EndIf
			Case cOpc == "2"
				cIdCli := AllTrim(SubStr(SLS->LS_DOCCF,1,11))
				cIdCli := Replicate("0",11-Len(cIdCli))+cIdCli
			Case cOpc == "4"
				cIdCli := SubStr(SLS->LS_CLIECF,1,30)
		EndCase
	Else
		dbSelectArea(cAlias)
		aAreaSA := GetArea()
		dbSetOrder(1)
		If dbSeek(xFilial(cAlias)+(cAliasSF3)->F3_CLIEFOR+(cAliasSF3)->F3_LOJA)
			cCpoCUIT := SubStr(cAlias,2,2)+"_CGC"
			cCpoNome := SubStr(cAlias,2,2)+"_NOME"
			cCpoTipo := SubStr(cAlias,2,2)+"_TIPO"
			cCpoAFIP := SubStr(cAlias,2,2)+"_AFIP"
			cCopRG	 := SubStr(cAlias,2,2)+"_RG"  
			cCopEnd	 := SubStr(cAlias,2,2)+"_END"  
			cCopEst	 := SubStr(cAlias,2,2)+"_EST"  
			cCopCep	 := SubStr(cAlias,2,2)+"_CEP"  
			cCopBai	 := SubStr(cAlias,2,2)+"_BAIRRO"  
			Do Case
				Case cOpc == "1"
					If cPaisLoc=="ARG"                 
					    cTipoDoc:=""
					    If FieldPos(SubStr(cAlias,2,2)+"_AFIP")>0  .And. !Empty(SubStr(cAlias,2,2)+"_AFIP")					      
				     		cTipoDoc:=(cAlias)->&cCpoAFIP					      
					    EndIf
					    If Empty(cTipoDoc)
							If (cAlias)->&cCpoTipo. == "F"
								cIdCli := "99"
							Else
								cIdCli := "80"
							Endif
						Else
							cIdCli := Alltrim(cTipoDoc)
						EndIf	
	                Else
						If (cAlias)->&cCpoTipo. == "F" .And. nValBrut < SuperGetMV("MV_LIMCFIS",,1000.00) 
							cIdCli := Space(02) //Eh consumidor final porem nao ultrapassa o valor minimo...
						Else
							If !Empty((cAlias)->&cCpoCUIT.)
								cIdCli := "80" //CUIT
							Else
								cIdCli := "??" //O tipo de documento nao foi informado no ato da venda/faturamento...
							EndIf
						Endif
					Endif	
				Case cOpc == "2" 
					cTipoDoc:=""
					If FieldPos(SubStr(cAlias,2,2)+"_AFIP")>0  .And. !Empty(SubStr(cAlias,2,2)+"_AFIP")
					   	cTipoDoc:=SubStr(cAlias,2,2)+"_AFIP"
					EndIf
					
					If !(Empty(cIDAnt))
						If Alltrim(cIDAnt) == "80" .Or. Alltrim(cIDAnt) == "86"  
							cIdCli := AllTrim(SubStr((cAlias)->&cCpoCUIT.,1,11))
						ElseIf ((cAlias)->(Fieldpos(cCopRG)) > 0)
							cIdCli := AllTrim(SubStr((cAlias)->&cCopRG.,1,11))
						Else
							cIdCli := Replicate("0",11)
						Endif
					ElseIf (cAlias)->&cCpoTipo. == "F" .And. nValBrut < SuperGetMV("MV_LIMCFIS",,1000.00) 
						cIdCli := Replicate("0",11)
					Else
						cIdCli := AllTrim(SubStr((cAlias)->&cCpoCUIT.,1,11))
					EndIf 
					
					
					If !Empty(cTipoDoc) .And.  !Empty((cAlias)->&cCpoCUIT)
						cIdCli := AllTrim(SubStr((cAlias)->&cCpoCUIT.,1,11))
					EndIf
					
					
					cIdCli := Replicate("0",11-Len(cIdCli))+cIdCli
				Case cOpc == "4"
					If (cAlias)->&cCpoTipo. == "F" .And. nValBrut < SuperGetMV("MV_LIMCFIS",,1000.00) 
						cIdCli := "CONSUMIDOR FINAL"+Space(14)
					Else
						cIdCli := SubStr((cAlias)->&cCpoNome.,1,30)
					EndIf
				Case cOpc == "5" .And. ((cAlias)->(Fieldpos(cCpoAFIP)) > 0)
			    	cIdCli := (cAlias)->&cCpoAFIP                 

	    			dbSelectArea("SX5")
					aAreaSX5 := GetArea()
					dbSetOrder(1)
					If dbSeek(xFilial("SX5")+"OC"+cIdCli)
						cIdCli := SubStr(X5DESCRI(),1,2)
					Else
						cIdCli := ""
					EndIf
					RestArea(aAreaSX5)		
			
			    	cIdCli := Replicate("0",2-Len(cIdCli))+cIdCli
				Case cOpc == "6" .And. !lNum
					cIdCli := Substr((cAlias)->&cCopEnd.,At(" ",(cAlias)->&cCopEnd.)+1,(At(",",(cAlias)->&cCopEnd.)-At(" ",(cAlias)->&cCopEnd.))-1)
				Case cOpc == "6" .And. lNum
					cIdCli := AllTrim(If(Val(Substr((cAlias)->&cCopEnd.,At(",",(cAlias)->&cCopEnd.)+1,Len(AllTrim((cAlias)->&cCopEnd.))))==0,Replicate("0",6 ),Substr((cAlias)->&cCopEnd.,At(",",(cAlias)->&cCopEnd.)+1,Len(AllTrim((cAlias)->&cCopEnd.)))))
				Case cOpc == "7" 
					cIdCli := AllTrim(SubStr((cAlias)->&cCopEst.,1,2))
				Case cOpc == "8"
					cIdCli := AllTrim(SubStr((cAlias)->&cCopCep.,1,8))
				Case cOpc == "9"
					cIdCli := AllTrim(SubStr((cAlias)->&cCopBai.,1,25))
			EndCase
		EndIf
		RestArea(aAreaSA)
	EndIf
	SLS->(RestArea(aAreaSLS))
ElseIf cOpc == "3"
	SLS->(dbSetOrder(1))
	If SLS->(dbSeek(xFilial("SLS")+(cAliasSF3)->F3_SERIE+(cAliasSF3)->F3_NFISCAL+(cAliasSF3)->F3_TIPO)) .And.; 
	   !Empty(SLS->LS_DOCCF)
		cIdCli := "05"
	Else 
		dbSelectArea(cAlias)
		aAreaSA := GetArea()
		dbSetOrder(1)
		If dbSeek(xFilial(cAlias)+(cAliasSF3)->F3_CLIEFOR+(cAliasSF3)->F3_LOJA)
			cCpoTipo := SubStr(cAlias,2,2)+"_TIPO"
			cIdCli   := AllTrim((cAlias)->&cCpoTipo.)
			cIdCli   := cIdCli+Space(TAMSX3("X5_CHAVE")[01]-Len(cIdCli))
		EndIf
		RestArea(aAreaSA)
		
		dbSelectArea("SX5")
		aAreaSX5 := GetArea()
		dbSetOrder(1)
		If dbSeek(xFilial("SX5")+"OD"+cIdCli)
			cIdCli := SubStr(X5DESCRI(),1,2)
		Else
			cIdCli := ""
		EndIf
		RestArea(aAreaSX5)		
	EndIf
Else
	cCpoRG1415 := SubStr(cAlias,2,2)+"_RG1415"
	cIdCli := Posicione(cAlias,1,xFilial(cAlias)+(cAliasSF3)->F3_CLIEFOR+(cAliasSF3)->F3_LOJA,cCpoRG1415)
EndIf
RestArea(aAreaAtu)
	
Return(cIdCli)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ GeraDadVen   ³Autor ³ Julio Cesar          ³Data³ 13/05/03 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Gera arquivo com os dados referentes as vendas realizadas. ³±± 
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function GeraDadVen(cNota,cSerie,cCliFor,cLoja,dDtaEmis,dDtaCanc,aDArq,cTES)

Local aAreaSF   := {}
Local aAreaSD   := {}
Local aAreaAtu  := GetArea()
Local aCab      := {}        //Array com os dados referentes as vendas (cabecalho)   
Local aLin      := {}        //Array com os dados referentes as vendas (linhas)   
Local aLinhas   := {}
Local aImps     := {}        
Local aAliq     := {}
Local aAliqAux  := {}
Local aTES      := {}
Local cStr      := ""
Local cAliasSF  := Iif(cTES > "500","SF2","SF1")     
Local cAliasSD  := Iif(cTES > "500","SD2","SD1")     
LocaL cAliasCF  := Iif(F3_TIPOMOV == "V","SA1","SA2")     
Local nTotIsen  := 0
Local nTotNAlc  := 0
Local lIsento   := .F.
Local lNAlcIVA  := .F.
Local lUltimo   := .F.
Local lNotaOk   := .F.
//Campos dos arquivos SF?
Local nSFFil    := (cAliasSF)->(FieldPos(SubStr(cAliasSF,2,2)+"_FILIAL"))
Local nSFDoc    := (cAliasSF)->(FieldPos(SubStr(cAliasSF,2,2)+"_DOC"))
Local nSFSer    := (cAliasSF)->(FieldPos(SubStr(cAliasSF,2,2)+"_SERIE")) 
Local nSFCliFor := (cAliasSF)->(FieldPos(SubStr(cAliasSF,2,2)+Iif(cAliasSF == "SF2","_CLIENTE","_FORNECE")))
Local nSFLoja   := (cAliasSF)->(FieldPos(SubStr(cAliasSF,2,2)+"_LOJA"))
Local nSFEcf    := (cAliasSF)->(FieldPos(SubStr(cAliasSF,2,2)+"_ECF"))
Local nSFDtaEmis:= (cAliasSF)->(FieldPos(SubStr(cAliasSF,2,2)+"_EMISSAO"))
Local nSFDtaDgt := (cAliasSF)->(FieldPos(SubStr(cAliasSF,2,2)+"_DTDIGIT")) 
Local nSFVBrut  := (cAliasSF)->(FieldPos(SubStr(cAliasSF,2,2)+"_VALBRUT"))
Local nSFVMerc  := (cAliasSF)->(FieldPos(SubStr(cAliasSF,2,2)+"_VALMERC"))
Local nSFMoeda  := (cAliasSF)->(FieldPos(SubStr(cAliasSF,2,2)+"_MOEDA"))
Local nSFTxMoeda:= (cAliasSF)->(FieldPos(SubStr(cAliasSF,2,2)+"_TXMOEDA"))
Local nSFEsp    := (cAliasSF)->(FieldPos(SubStr(cAliasSF,2,2)+"_ESPECIE")) 
Local nSFTipo   := (cAliasSF)->(FieldPos(SubStr(cAliasSF,2,2)+"_TIPO"))
//Campos dos arquivos SD?
Local nSDDoc    := (cAliasSD)->(FieldPos(SubStr(cAliasSD,2,2)+"_DOC"))
Local nSDSer    := (cAliasSD)->(FieldPos(SubStr(cAliasSD,2,2)+"_SERIE"))
Local nSDCliFor := (cAliasSD)->(FieldPos(SubStr(cAliasSD,2,2)+Iif(cAliasSD == "SD2","_CLIENTE","_FORNECE")))
Local nSDLoja   := (cAliasSD)->(FieldPos(SubStr(cAliasSD,2,2)+"_LOJA"))
Local nSDEsp    := (cAliasSD)->(FieldPos(SubStr(cAliasSD,2,2)+"_ESPECIE"))
Local nSDEmis   := (cAliasSD)->(FieldPos(SubStr(cAliasSD,2,2)+"_EMISSAO"))
Local nSDQtde   := (cAliasSD)->(FieldPos(SubStr(cAliasSD,2,2)+"_QUANT"))
Local nSDUm     := (cAliasSD)->(FieldPos(SubStr(cAliasSD,2,2)+"_UM"))
Local nSDPrUnit := (cAliasSD)->(FieldPos(SubStr(cAliasSD,2,2)+Iif(cAliasSD == "SD2","_PRCVEN","_VUNIT")))
Local nSDDesc   := (cAliasSD)->(FieldPos(SubStr(cAliasSD,2,2)+Iif(cAliasSD == "SD2","_DESCON","_VALDESC")))
Local nSDTotal  := (cAliasSD)->(FieldPos(SubStr(cAliasSD,2,2)+"_TOTAL"))
Local nSDTes    := (cAliasSD)->(FieldPos(SubStr(cAliasSD,2,2)+"_TES"))
Local nI := 0
Local nX := 0
Local nRegSF := 0
// Moeda e Taxa para a factura/nota corrente.
Private nMoedaCor := 0
Private nTaxaMoeda:= 0
Private dDtaDgt 

// Caso o campo de Data da digitacao nao exista considera a data de emissao.
If nSFDtaDgt == 0
	nSFDtaDgt := nSFDtaEmis
EndIf
//Eh necessario fazer isso para que os dados das facturas ou notas canceladas
//sejam considerados nos arquivos...
If !Empty(dDtaCanc)
	SET DELETED OFF
EndIf

dbSelectArea(cAliasSF)
aAreaSF := GetArea()
dbSetOrder(1)
If dbSeek(xFilial(cAliasSF)+cNota+cSerie+cCliFor+cLoja)	
	If AllTrim(FieldGet(nSFEsp)) <> AllTrim((cAliasSF3)->F3_ESPECIE)
		nRegSF:=Recno()
		While !Eof() .And. xFilial(cAliasSF)+cNota+cSerie+cCliFor+cLoja ==; 
			  FieldGet(nSFFil)+FieldGet(nSFDoc)+FieldGet(nSFSer)+FieldGet(nSFCliFor)+FieldGet(nSFLoja)
			  
			If AllTrim(FieldGet(nSFEsp)) <> AllTrim((cAliasSF3)->F3_ESPECIE)
				dbSkip()
			Else
				lNotaOk := .T.
				Exit
			EndIf
		End
	Else
		lNotaOk := .T.
	EndIf

	If !lNotaOk
		//A factura nao foi encontrada no arquivo SF? correspondente...
		VerifErro(,@aDArq,"5",cNota,cSerie,cCliFor,cLoja,,(cAliasSF3)->F3_ESPECIE,cAliasSF)

		//Ativa o SET para nao visualizar mais a facturas ou notas canceladas...
		If !Empty(dDtaCanc)
			SET DELETED ON
		EndIf   	

		//Retorna as areas originais...
		DbGoto(nRegSF)
		//RestArea(aAreaSF)
		//RestArea(aAreaAtu)
	EndIf
		
	// Armazena a moeda e a respectiva taxa...	
	nMoedaCor  := FieldGet(nSFMoeda)	
	nTaxaMoeda := FieldGet(nSFTxMoeda)
	dDtaDgt    := FieldGet(nSFDtaDgt)
	
	If aDArq[REG_REGVEN][3][04][01] == Nil
		aDArq[REG_REGVEN][3][01][01] := "2"
		aDArq[REG_REGVEN][3][02][01] := SubStr(cData,1,6)
		aDArq[REG_REGVEN][3][03][01] := Space(29)
		aDArq[REG_REGVEN][3][04][02] := 0		
		aDArq[REG_REGVEN][3][05][01] := Space(10) 
		aDArq[REG_REGVEN][3][06][01] := SubStr(SM0->M0_CGC,1,11)
		aDArq[REG_REGVEN][3][07][01] := Space(30)  
		aDArq[REG_REGVEN][3][08][02] := 0
		aDArq[REG_REGVEN][3][09][02] := 0
		aDArq[REG_REGVEN][3][10][02] := 0
		aDArq[REG_REGVEN][3][11][01] := Space(04)
		aDArq[REG_REGVEN][3][12][02] := 0
		aDArq[REG_REGVEN][3][13][02] := 0
		aDArq[REG_REGVEN][3][14][02] := 0
		aDArq[REG_REGVEN][3][15][02] := 0
		aDArq[REG_REGVEN][3][16][02] := 0
		aDArq[REG_REGVEN][3][17][02] := 0
		aDArq[REG_REGVEN][3][18][02] := 0
		aDArq[REG_REGVEN][3][19][01] := Space(122)
	EndIf		

	aAreaSD := (cAliasSD)->(GetArea())		
	If cAliasSD == "SD2"
		(cAliasSD)->(dbSetOrder(3))
	Else
		(cAliasSD)->(dbSetOrder(1))
	EndIf

    //Nao foi encontrado o registro no arquivo SD? correspondente..	
	If !(cAliasSD)->(dbSeek(xFilial(cAliasSD)+(cAliasSF)->(FieldGet(nSFDoc))+(cAliasSF)->(FieldGet(nSFSer))+(cAliasSF)->(FieldGet(nSFCliFor))+(cAliasSF)->(FieldGet(nSFLoja))))
	   	VerifErro(,@aDArq,"6",cNota,cSerie,cCliFor,cLoja,,(cAliasSF3)->F3_ESPECIE,cAliasSD)
    EndIf            
    
	While !(cAliasSD)->(Eof()) .And.	xFilial(cAliasSD)+(cAliasSD)->(FieldGet(nSDDoc))+(cAliasSD)->(FieldGet(nSDSer))+(cAliasSD)->(FieldGet(nSDCliFor))+(cAliasSD)->(FieldGet(nSDLoja)) ==;
  	                           			xFilial(cAliasSD)+FieldGet(nSFDoc)+FieldGet(nSFSer)+FieldGet(nSFCliFor)+FieldGet(nSFLoja)
 		
		If AllTrim(FieldGet(nSFEsp)) <> AllTrim((cAliasSD)->(FieldGet(nSDEsp)))
			(cAliasSD)->(dbSkip())
			Loop
		EndIf
 		
		aAliqAux := PesqInfImp(cAliasSD,IVA,"3",(cAliasSD)->(FieldGet(nSDTes)),"2")
    	For nI := 1 To Len(aAliqAux)
			If aScan(aAliq,{|x| x == aAliqAux[nI]}) == 0
				//Adiciona a aliquota no array de aliquotas...
				AAdd(aAliq,aAliqAux[nI]) 
			EndIf

			//Controla se a venda possui itens isentos ou nao alcancados pelo IVA
			//e totaliza os respectivos valores.
			If aAliqAux[nI] == 0
				IndExGrv(aAliqAux[nI],@nTotIsen,@nTotNAlc,cAliasSD,@lNAlcIVA)
				lIsento := .T.
			EndIf
		Next nI
	
		//Gera array com o total de cada imposto...
		AAdd(aImps,aClone(aDImps))

		(cAliasSD)->(dbSkip())
 	End

	//Caso existam somente duas aliquotas de IVA e uma delas e 0(Zero) nao existe
	//a necessidade de se gerar duas linhas no arquivo, tudo devera ser gravado em
	//uma unica linha. 	                 
 	If Len(aAliq) == 2
		If (nI := aScan(aAliq,{|x| x == 0})) > 0
			aDel(aAliq,nI)
			aSize(aAliq,Len(aAliq)-1)
		EndIf
 	EndIf

	For nI := 1 To Len(aAliq)
		//Os campos de 01 a 10 sempre sao iguais, independente da aliquota.
		AAdd(aCab,"1") 								//Campo 01 - Tipo de Registro
		AAdd(aCab,Dtos(FieldGet(nSFDtaEmis)))		//Campo 02 - Data do comprovante
		AAdd(aCab,M991TpComp(cAliasSF,FieldGet(nSFSer),FieldGet(nSFEsp)))	//Campo 03 - Tipo de comprovante
		//Campo 04 - Controlador Fiscal		
		If cAliasSF == "SF2"
			AAdd(aCab,Iif(F2_ECF<>"1",Space(01),"C"))
		Else
			AAdd(aCab,Iif(F1_ECF<>"1",Space(01),"C"))
 		EndIf
		AAdd(aCab,PadL(AllTrim(SubStr(FieldGet(nSFDoc),1,4)),4,"0"))	//Campo 05 - Ponto de Venda
		AAdd(aCab,PadL(AllTrim(SubStr(FieldGet(nSFDoc),5,8)),20,"0"))	//Campo 06 - Numero do comprovante
		AAdd(aCab,PadL(AllTrim(SubStr(FieldGet(nSFDoc),5,8)),20,"0"))	//Campo 07 - Numero do comprovante "Ate" (Range de Facturas)
		AAdd(aCab,PesqIdCliFor(cAliasCF,"1",FieldGet(nSFVBrut)))	//Campo 08 - Codigo de documento identificador do comprador
		AAdd(aCab,PesqIdCliFor(cAliasCF,"2",FieldGet(nSFVBrut)))	//Campo 09 - Numero de identificacao do comprador
		AAdd(aCab,PesqIdCliFor(cAliasCF,"4",FieldGet(nSFVBrut)))	//Campo 10 - Nome e sobrenome do comprador ou denominacao do comprador
		                   
		//O conteudo varia conforme a aliquota do IVA
		AAdd(aCab,Iif(nI==Len(aAliq),FieldGet(nSFVBrut),0))		//Campo 11 - Valor total da transacao (Totaliza no Campo 08 do Arq. de Detalhe)
		AAdd(aCab,nTotNAlc)											//Campo 12 - Valor total de itens que nao tiveram incidencia de IVA (Totaliza no Campo 09 do Arq. de Detalhe)
		AAdd(aCab,TotCat(IVA,"1",aImps,"2",,aAliq,aAliq[nI],.F.))	//Campo 13 - Importe Neto Gravado (Totaliza no Campo 10 do Arq. de Detalhe)
		AAdd(aCab,aAliq[nI]) 										//Campo 14 - Aliquota de IVA        
		AAdd(aCab,TotCat(IVA,"2",aImps,"2",,aAliq,aAliq[nI],.F.))	//Campo 15 - Imposto Liquidado (Totaliza no Campo 12 do Arq. de Detalhe)
		AAdd(aCab,TotCat(RNI,"2",aImps,"2"))						//Campo 16 - Imposto Liquidado a RNI o percepcion a no categorizados (Totaliza no Campo 13 do Arq. de Detalhe)
		If Len(aAliq) == 1 .Or. (Len(aAliq) > 2 .And. aAliq[nI] == 0)
			AAdd(aCab,nTotIsen)		//Campo 17 - Importe de operacoes Isentas (Totaliza no Campo 14 do Arq. de Detalhe)
		Else
			AAdd(aCab,0)			//Campo 17 - Importe de operacoes Isentas (Totaliza no Campo 14 do Arq. de Detalhe)
		EndIf
        //Os valores so serao totalizados no ultimo registro a ser gerado...
		AAdd(aCab,Iif(nI==Len(aAliq),TotCat(PIN,"2",aImps,"2"),0))	//Campo 18 - Importe de percepciones ou pagos a conta sobre impostos nacionais (Totaliza no Campo 15 do Arq. de Detalhe)
		AAdd(aCab,Iif(nI==Len(aAliq),TotCat(PIB,"2",aImps,"2"),0))	//Campo 19 - Importe de percepciones de ingresos brutos (Totaliza no Campo 16 do Arq. de Detalhe)
		AAdd(aCab,Iif(nI==Len(aAliq),TotCat(PIM,"2",aImps,"2"),0))	//Campo 20 - Importe de percepciones de impostos municipais (Totaliza no Campo 17 do Arq. de Detalhe)
		AAdd(aCab,Iif(nI==Len(aAliq),TotCat(PII,"2",aImps,"2"),0))	//Campo 21 - Importe de impostos internos (Totaliza no Campo 18 do Arq. de Detalhe)
		
		//Os campos de 22 a 30 sempre sao iguais, independente da aliquota.
		AAdd(aCab,PesqIdCliFor(cAliasCF,"3"))	//Campo 22 - Tipo de responsavel
		AAdd(aCab,PMoeda(FieldGet(nSFMoeda)))	//Campo 23 - Codigo da moeda
		AAdd(aCab,MontaValor(FieldGet(nSFTxMoeda),"@E 9999.999999",10))	//Campo 24 - Taxa da moeda
		AAdd(aCab,TotCat(IVA,"3",aImps,"1"))								//Campo 25 - Quantidade de aliquotas de IVA
		AAdd(aCab,PesqCodOp(,aCab[15],FieldGet(nSFCliFor),FieldGet(nSFLoja),cAliasCF,"2",aAliq[nI],lNAlcIVA))	//Campo 26 - Codigo da operacao
		AAdd(aCab,PesqCAI(cAliasSF,"1"))	//Campo 27 - CAI
		AAdd(aCab,PesqCAI(cAliasSF,"2"))	//Campo 28 - Data de vencimento
		AAdd(aCab,Iif(Empty(dDtaCanc),Replicate("0",8),Dtos(dDtaCanc)))	//Campo 29 - Data de Anulacao do comprovante               
		AAdd(aCab,Space(75))	//Campo 30 - Informacao Adicional - Acredito que seja util criar um PE...

		//Determina se eh a ultima linha a ser gerada para o registro corrente
		lUltimo := (nI == Len(aAliq))
		
		//Executa funcao que verifica possiveis erros na geracao dos dados...
		VerifErro(aCab,@aDArq,"4",FieldGet(nSFDoc),FieldGet(nSFSer),FieldGet(nSFCliFor),;
		          FieldGet(nSFLoja),lIsento,FieldGet(nSFEsp),cAliasSF,lUltimo,;
		          Iif(PesqIdCliFor(cAliasCF,"5")=="1",.T.,.F.))
	
		//Totaliza a quantidade de linhas do tipo 1		
		aDArq[REG_REGVEN][03][04][02] += 1
	
		For nX := 11 To 21
			If nX == 14
				//Formata o dado para a gravacao do arquivo texto
				//Para a aliquota de imposto a picture eh diferente
				aCab[nX] := MontaValor(aCab[nX],"@E 99.99",4)
			Else
				//Converte para a moeda 1
				If nMoedaCor <> 1
					aCab[nX] := Round(xMoeda(aCab[nX],nMoedaCor,1,dDtaDgt,nDecimais+1,nTaxaMoeda),nDecimais)				
				EndIf
				
				If Empty(dDtaCanc)
					//Calcula os totais gerais...
					aDArq[REG_REGVEN][03][nX-3][02] += (aCab[nX] * Iif(aCab[3]$"03|08|13|21|38|85",-1,1))
				Endif
				
				//Formata os dados para a gravacao do arquivo texto
				aCab[nX] := MontaValor(aCab[nX],"@E 9999999999999.99",15,.F.)
			EndIf
		Next nX
			
		//Gera Linha que sera gravada no arquivo de cabecalho
		aEval(aCab,{|x| cStr += x})
		cStr += Chr(13)+Chr(10)
			
		//Grava linha no arquivo...
		TrabArqTxt(.F.,@aDArq,REG_REGVEN,aDArq[REG_REGVEN][1],aDArq[REG_REGVEN][2],cStr)	
		
		//Limpa variaveis para a gravacao dos novos dados...
		aCab := {}
		cStr := ""
	Next nI

	//Trata os dados que serao gravados no arquivo texto
	aDArq[REG_REGVEN][03][04][01] := MontaValor(aDArq[REG_REGVEN][03][04][02],"999999999999",12)	
	For nI := 08 To 18
		If nI <> 11
			aDArq[REG_REGVEN][03][nI][01] := MontaValor(aDArq[REG_REGVEN][03][nI][02],"@E 9999999999999.99",15,.F.)
		EndIf
	Next nI
	                 
	//Restaura a area original do arquivo SD?...
	RestArea(aAreaSD)
Else
	//A factura nao foi encontrada no arquivo SF? correspondente...
	VerifErro(,@aDArq,"5",cNota,cSerie,cCliFor,cLoja,,(cAliasSF3)->F3_ESPECIE,cAliasSF)
EndIf             

//Ativa o SET para nao visualizar mais a facturas ou notas canceladas...
If !Empty(dDtaCanc)
	SET DELETED ON
EndIf

//Retorna as areas originais...
RestArea(aAreaSF)
RestArea(aAreaAtu)

Return Nil

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ GeraDadCom   ³Autor ³ Julio Cesar          ³Data³ 13/05/03 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Gera o arquivo com os dados referentes a Compras           ³±± 
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function GeraDadCom(cNota,cSerie,cCliFor,cLoja,dDtaEmis,dDtaCanc,aDArq,cTES)

Local aAreaSF   := {}  
Local aAreaSD   := {}
Local aAreaAtu  := GetArea()
Local aCab      := {}        //Array com os dados referentes as vendas (cabecalho)   
Local aAliq     := {}        //Array com as aliquotas de IVA
Local aImps     := {}
Local cAliasSF  := Iif(cTES > "500","SF2","SF1")     
Local cAliasSD  := Iif(cTES > "500","SD2","SD1")     
LocaL cAliasCF  := Iif(F3_TIPOMOV == "V","SA1","SA2")
Local cStr      := ""          
Local aAliqAux  := {}
Local nTotIsen  := 0
Local nTotNAlc  := 0
Local nI  		:= 0
Local lIsento   := .F.
Local lNAlcIVA  := .F.
Local lUltimo   := .F.
Local lNotaOk   := .F.
//Campos dos arquivos SF?
Local nSFFil    := (cAliasSF)->(FieldPos(SubStr(cAliasSF,2,2)+"_FILIAL"))
Local nSFDoc    := (cAliasSF)->(FieldPos(SubStr(cAliasSF,2,2)+"_DOC"))
Local nSFSer    := (cAliasSF)->(FieldPos(SubStr(cAliasSF,2,2)+"_SERIE"))
Local nSFCliFor := (cAliasSF)->(FieldPos(SubStr(cAliasSF,2,2)+Iif(cAliasSF == "SF2","_CLIENTE","_FORNECE")))
Local nSFLoja   := (cAliasSF)->(FieldPos(SubStr(cAliasSF,2,2)+"_LOJA"))
Local nSFEcf    := (cAliasSF)->(FieldPos(SubStr(cAliasSF,2,2)+"_ECF"))
Local nSFDtaEmis:= (cAliasSF)->(FieldPos(SubStr(cAliasSF,2,2)+"_EMISSAO"))
Local nSFDtaRCon:= (cAliasSF)->(FieldPos(SubStr(cAliasSF,2,2)+"_DTLANC")) 
Local nSFDtaDgt := (cAliasSF)->(FieldPos(SubStr(cAliasSF,2,2)+"_DTDIGIT")) 
Local nSFVBrut  := (cAliasSF)->(FieldPos(SubStr(cAliasSF,2,2)+"_VALBRUT"))
Local nSFVMerc  := (cAliasSF)->(FieldPos(SubStr(cAliasSF,2,2)+"_VALMERC"))
Local nSFMoeda  := (cAliasSF)->(FieldPos(SubStr(cAliasSF,2,2)+"_MOEDA"))
Local nSFTxMoeda:= (cAliasSF)->(FieldPos(SubStr(cAliasSF,2,2)+"_TXMOEDA"))
Local nSFEsp    := (cAliasSF)->(FieldPos(SubStr(cAliasSF,2,2)+"_ESPECIE")) 
Local nSFDesc   := (cAliasSF)->(FieldPos(SubStr(cAliasSF,2,2)+"_DESCONT"))
Local nX := 0
//Campos dos arquivos SD?
Local nSDDoc    := (cAliasSD)->(FieldPos(SubStr(cAliasSD,2,2)+"_DOC"))
Local nSDSer    := (cAliasSD)->(FieldPos(SubStr(cAliasSD,2,2)+"_SERIE"))
Local nSDCliFor := (cAliasSD)->(FieldPos(SubStr(cAliasSD,2,2)+Iif(cAliasSD == "SD2","_CLIENTE","_FORNECE")))
Local nSDLoja   := (cAliasSD)->(FieldPos(SubStr(cAliasSD,2,2)+"_LOJA"))
Local nSDTes    := (cAliasSD)->(FieldPos(SubStr(cAliasSD,2,2)+"_TES"))
Local nSDEsp    := (cAliasSD)->(FieldPos(SubStr(cAliasSD,2,2)+"_ESPECIE"))
Local nRegSF := 0
// Moeda, Taxa e Data de Emissao para a factura/nota corrente.
Private nMoedaCor := 0
Private nTaxaMoeda:= 0
Private dDtaDgt 

// Caso o campo de Data da digitacao nao exista considera a data de emissao.
If nSFDtaDgt == 0
	nSFDtaDgt := nSFDtaEmis
EndIf
//Eh necessario fazer isso para que os dados das facturas ou notas canceladas
//sejam considerados nos arquivos...
If !Empty(dDtaCanc)
	SET DELETED OFF
EndIf

dbSelectArea(cAliasSF)
aAreaSF := GetArea()
dbSetOrder(1)
If dbSeek(xFilial(cAliasSF)+cNota+cSerie+cCliFor+cLoja)
	If AllTrim(FieldGet(nSFEsp)) <> AllTrim((cAliasSF3)->F3_ESPECIE)
		nRegSF:=Recno()
		While !Eof() .And. xFilial(cAliasSF)+cNota+cSerie+cCliFor+cLoja ==;
			  FieldGet(nSFFil)+FieldGet(nSFDoc)+FieldGet(nSFSer)+FieldGet(nSFCliFor)+FieldGet(nSFLoja) 
			  
			If AllTrim(FieldGet(nSFEsp)) <> AllTrim((cAliasSF3)->F3_ESPECIE)
				dbSkip()
			Else
				lNotaOk := .T.
				Exit
			EndIf
		End
	Else
		lNotaOk := .T.
	EndIf
	
	If !lNotaOk
		//A factura nao foi encontrada no arquivo SF? correspondente...
		VerifErro(,@aDArq,"5",cNota,cSerie,cCliFor,cLoja,,(cAliasSF3)->F3_ESPECIE,cAliasSF)

		//Ativa o SET para nao visualizar mais a facturas ou notas canceladas...
		If !Empty(dDtaCanc)
			SET DELETED ON
		EndIf

		//Retorna area original da entrada da rotina...
		DbGoto(nRegSF)
		//RestArea(aAreaSF)
		//RestArea(aAreaAtu)
		Return
	EndIf
	
	// Armazena a moeda e a respectiva taxa...	
	nMoedaCor  := FieldGet(nSFMoeda)	
	nTaxaMoeda := FieldGet(nSFTxMoeda)
	dDtaDgt    := FieldGet(nSFDtaDgt)

	If aDArq[REG_REGCOM][3][04][01] == Nil
		aDArq[REG_REGCOM][3][01][01] := "2"
		aDArq[REG_REGCOM][3][02][01] := SubStr(cData,1,6)
		aDArq[REG_REGCOM][3][03][01] := Space(10)
		aDArq[REG_REGCOM][3][04][02] := 0		
		aDArq[REG_REGCOM][3][05][01] := Space(31) 
		aDArq[REG_REGCOM][3][06][01] := SubStr(SM0->M0_CGC,1,11)
		aDArq[REG_REGCOM][3][07][01] := Space(30)  
		aDArq[REG_REGCOM][3][08][02] := 0
		aDArq[REG_REGCOM][3][09][02] := 0
		aDArq[REG_REGCOM][3][10][02] := 0
		aDArq[REG_REGCOM][3][11][01] := Space(04)
		aDArq[REG_REGCOM][3][12][02] := 0
		aDArq[REG_REGCOM][3][13][02] := 0
		aDArq[REG_REGCOM][3][14][02] := 0
		aDArq[REG_REGCOM][3][15][02] := 0
		aDArq[REG_REGCOM][3][16][02] := 0
		aDArq[REG_REGCOM][3][17][02] := 0
		aDArq[REG_REGCOM][3][18][02] := 0
		aDArq[REG_REGCOM][3][19][01] := Space(114)
	EndIf		

	aAreaSD := (cAliasSD)->(GetArea())		
	If cAliasSD == "SD2"
		(cAliasSD)->(dbSetOrder(3))
	Else
		(cAliasSD)->(dbSetOrder(1))
	EndIf

    //Nao foi encontrado o registro no arquivo SD? correspondente..
	If !(cAliasSD)->(dbSeek(xFilial(cAliasSD)+(cAliasSF)->(FieldGet(nSFDoc))+(cAliasSF)->(FieldGet(nSFSer))+(cAliasSF)->(FieldGet(nSFCliFor))+(cAliasSF)->(FieldGet(nSFLoja))))
    	VerifErro(,@aDArq,"6",cNota,cSerie,cCliFor,cLoja,,(cAliasSF3)->F3_ESPECIE,cAliasSD)
	EndIf
	
	While !(cAliasSD)->(Eof()) .And.	xFilial(cAliasSD)+(cAliasSD)->(FieldGet(nSDDoc))+(cAliasSD)->(FieldGet(nSDSer))+(cAliasSD)->(FieldGet(nSDCliFor))+(cAliasSD)->(FieldGet(nSDLoja)) ==;
  	                           			xFilial(cAliasSD)+FieldGet(nSFDoc)+FieldGet(nSFSer)+FieldGet(nSFCliFor)+FieldGet(nSFLoja)
 		
		If AllTrim(FieldGet(nSFEsp)) <> AllTrim((cAliasSD)->(FieldGet(nSDEsp)))
			(cAliasSD)->(dbSkip())
			Loop
		EndIf
 		
		aAliqAux := PesqInfImp(cAliasSD,IVA,"3",(cAliasSD)->(FieldGet(nSDTes)),"2")
		For nI := 1 To Len(aAliqAux)
			If aScan(aAliq,{|x| x == aAliqAux[nI]}) == 0
				//Adiciona a aliquota no array de aliquotas...
				AAdd(aAliq,aAliqAux[nI]) 
			EndIf

			//Controla se a venda possui itens isentos ou nao alcancados pelo IVA
			//e totaliza os respectivos valores.
			If aAliqAux[nI] == 0
				IndExGrv(aAliqAux[nI],@nTotIsen,@nTotNAlc,cAliasSD,@lNAlcIVA)
				lIsento := .T.
			EndIf
		Next nI
	
		//Gera array com o total de cada imposto...
		AAdd(aImps,aClone(aDImps))
	
 		(cAliasSD)->(dbSkip())
 	End

	//Caso existam somente duas aliquotas de IVA e uma delas e 0(Zero) nao existe
	//a necessidade de se gerar duas linhas no arquivo, tudo devera ser gravado em
	//uma unica linha. 	                 
 	If Len(aAliq) == 2
		If (nI := aScan(aAliq,{|x| x == 0})) > 0
			aDel(aAliq,nI)
			aSize(aAliq,Len(aAliq)-1)
		EndIf
 	EndIf

	//Valorizar array com os dados que irao compor a linha para gravacao do arquivo 
	//de cabecalho...
	For nI := 1 To Len(aAliq)
		AAdd(aCab,"1")                     		//Campo 01 - Tipo de Registro
		AAdd(aCab,Dtos(FieldGet(nSFDtaEmis)))	//Campo 02 - Data do comprovante
		AAdd(aCab,M991TpComp(cAliasSF,FieldGet(nSFSer),FieldGet(nSFEsp)))	//Campo 03 - Tipo de comprovante 
		//Campo 04 - Controlador Fiscal		
		If cAliasSF == "SF2"
			AAdd(aCab,Iif(F2_ECF<>"1",Space(01),"C"))
		Else
			AAdd(aCab,Iif(F1_ECF<>"1",Space(01),"C"))
	 	EndIf
	 	cSFDoc := M991NrComp(FieldGet(nSFDoc),aCab[3])
		AAdd(aCab,PadL(AllTrim(SubStr(cSFDoc,1,4)),4,"0"))	//Campo 05 - Ponto de Venda
		AAdd(aCab,PadL(Alltrim(SubStr(cSFDoc,5,8)),20,"0"))	//Campo 06 - Numero do comprovante			
        
        If !Empty(FieldGet(nSFDtaRCon))
	        AAdd(aCab,Dtos(FieldGet(nSFDtaRCon)))	//Campo 07 - Data de Registro Contabil
	 	Else
	 		AAdd(aCab,Replicate("0",8)) 			//Campo 07 - Data de Registro Contabil
	 	EndIf
        
		//Se trata de uma nota de importacao...
		If cAliasSF == "SF1" .And. !Empty(SF1->F1_HAWB)
			GrvDadosImp(@aCab,SF1->F1_HAWB,SF1->F1_TIPO_NF)
		Else
			//A funcao GRVDADOSIMP() inicializa a variavel de retorno da mesma forma feita abaixo. 
			//Se esta forma for modificada, verificar a necessidade de alteracao nessa funcao.
			AAdd(aCab,Replicate("0",3))			//Campo 08 - Codigo de Aduana
			AAdd(aCab,Space(4))   				//Campo 09 - Codigo de Destino
			AAdd(aCab,Replicate("0",6))			//Campo 10 - Numero de Despacho
			AAdd(aCab,Space(1))					//Campo 11 - Digito verificador do numero do despacho
		EndIf
		AAdd(aCab,PesqIdCliFor(cAliasCF,"1",FieldGet(nSFVBrut)))  	//Campo 12 - Codigo de documento identificador do vendedor
		AAdd(aCab,PesqIdCliFor(cAliasCF,"2",FieldGet(nSFVBrut)))	//Campo 13 - Numero de identificacao do vendedor
		AAdd(aCab,PesqIdCliFor(cAliasCF,"4",FieldGet(nSFVBrut)))	//Campo 14 - Nome e sobrenome do comprador ou denominacao do fornecedor
		//O conteudo existente no intervalo entre os campos 15 a 25 sera
		//totalizado posteriomente.		
		AAdd(aCab,Iif(nI==Len(aAliq),FieldGet(nSFVBrut),0))	//Campo 15 - Valor total da transacao (Totaliza no Campo 08 do Arq. de Detalhe)
		AAdd(aCab,nTotNAlc)										//Campo 16 - Valor total que nao teve incidencia de IVA (Totaliza no Campo 09 do Arq. de Detalhe)
		AAdd(aCab,TotCat(IVA,"1",aImps,"2",,aAliq,aAliq[nI],.F.))	//Campo 17 - Base de calculo do IVA (Totaliza no Campo 10 do Arq. de Detalhe)
		AAdd(aCab,aAliq[nI])  									//Campo 18 - Aliquota de IVA
		AAdd(aCab,TotCat(IVA,"2",aImps,"2",,aAliq,aAliq[nI],.F.))	//Campo 19 - Total de IVA calculado  (Totaliza no Campo 12 do Arq. de Detalhe)
		If Len(aAliq) == 1 .Or. (Len(aAliq) > 2 .And. aAliq[nI] == 0)
			AAdd(aCab,nTotIsen)	//Campo 20 - Importe de operacoes isentas (Totaliza no Campo 13 do Arq. de Detalhe)
		Else
			AAdd(aCab,0)		//Campo 20 - Importe de operacoes isentas (Totaliza no Campo 13 do Arq. de Detalhe)
		EndIf
		//Os dados so serao gravados no ultimo registro a ser gerado...
		AAdd(aCab,Iif(nI==Len(aAliq),TotCat(IVP,"2",aImps,"2"),0))	//Campo 21 - Importe de percepcoes ou pagamentos a conta do imposto de valor agregado (Totaliza no Campo 14 do Arq. de Detalhe)		
		AAdd(aCab,Iif(nI==Len(aAliq),TotCat(PIN,"2",aImps,"2"),0))	//Campo 22 - Importe de percepcoes ou pagamentos a conta de impostos nacionais (Totaliza no Campo 15 do Arq. de Detalhe)
		AAdd(aCab,Iif(nI==Len(aAliq),TotCat(PIB,"2",aImps,"2"),0))	//Campo 23 - Importe de ingressos brutos (Totaliza no Campo 16 do Arq. de Detalhe)
		AAdd(aCab,Iif(nI==Len(aAliq),TotCat(PIM,"2",aImps,"2"),0))	//Campo 24 - Importe de percepcoes de impostos municipais (Totaliza no Campo 17 do Arq. de Detalhe)
		AAdd(aCab,Iif(nI==Len(aAliq),TotCat(PII,"2",aImps,"2"),0))	//Campo 25 - Importe de impostos internos (Totaliza no Campo 18 do Arq. de Detalhe)

		//Os campos de 26 a 33 sempre sao iguais, independente da aliquota.
		AAdd(aCab,PesqIdCliFor(cAliasCF,"3"))	//Campo 26 - Tipo de responsavel
		AAdd(aCab,PMoeda(FieldGet(nSFMoeda)))	//Campo 27 - Codigo da moeda
		AAdd(aCab,MontaValor(IIf(FieldGet(nSFTxMoeda)<=1,1,FieldGet(nSFTxMoeda)),"@E 9999.999999",10))	//Campo 28 - Taxa da moeda
		AAdd(aCab,TotCat(IVA,"3",aImps,"1"))								//Campo 29 - Quantidade de aliquotas de IVA
		AAdd(aCab,PesqCodOp(,aCab[21],FieldGet(nSFCliFor),FieldGet(nSFLoja),cAliasCF,"2",aAliq[nI],lNAlcIVA))	//Campo 30 - Codigo da operacao
		AAdd(aCab,PesqCAI(cAliasSF,"1"))	//Campo 31 - CAI
		AAdd(aCab,PesqCAI(cAliasSF,"2"))	//Campo 32 - Data de vencimento
		AAdd(aCab,Space(75))				//Campo 33 - Informacao Adicional - Acredito que seja util criar um PE...

		//Determina se eh a ultima linha a ser gerada para o registro corrente
		lUltimo := (nI == Len(aAliq))

		//Executa funcao que verifica possiveis erros na geracao dos dados...
		VerifErro(aCab,@aDArq,"2",FieldGet(nSFDoc),FieldGet(nSFSer),FieldGet(nSFCliFor),;
		          FieldGet(nSFLoja),lIsento,FieldGet(nSFEsp),cAliasSF,lUltimo,;
		          Iif(PesqIdCliFor(cAliasCF,"5")=="1",.T.,.F.))

		//Total de linhas do Tipo 1
	    aDArq[REG_REGCOM][3][04][02] += 1

		//Totaliza o valor bruto...
		For nX := 15 To 25
			If nX == 18
				//Formata o dado para a gravacao do arquivo texto
				//Para a aliquota de imposto a picture eh diferente
				aCab[nX] := MontaValor(aCab[nX],"@E 99.99",4)
			Else
				//Converte para a moeda 1
				If nMoedaCor <> 1
					aCab[nX] := Round(xMoeda(aCab[nX],nMoedaCor,1,dDtaDgt,nDecimais+1,nTaxaMoeda),nDecimais)				
				EndIf

				//Calcula os totais gerais...
				aDArq[REG_REGCOM][03][nX-7][02] += (aCab[nX] * Iif(aCab[3]$"03|08|13|21|38|85",-1,1))

				//Formata os dados para a gravacao do arquivo texto
				aCab[nX] := MontaValor(aCab[nX],"@E 9999999999999.99",15,.F.)
			EndIf
		Next nX
				                     
		//Gera Linha que sera gravada no arquivo de cabecalho
		aEval(aCab,{|x| cStr += x})
		cStr += Chr(13)+Chr(10)
			
		//Grava linha no arquivo...
		TrabArqTxt(.F.,@aDArq,REG_REGCOM,aDArq[REG_REGCOM][1],aDArq[REG_REGCOM][2],cStr)	
                  
    	//Limpa variaveis para a gravacao dos novos dados... 
    	aCab := {}
    	cStr := ""
    Next nI

	//Trata os dados que serao gravados no arquivo texto
	aDArq[REG_REGCOM][03][04][01] := MontaValor(aDArq[REG_REGCOM][3][04][02],"999999999999",12)
	For nI := 8 To 18
		If nI <> 11
			aDArq[REG_REGCOM][03][nI][01] := MontaValor(aDArq[REG_REGCOM][03][nI][02],"@E 9999999999999.99",15,.F.)
		EndIf
	Next nI
	
	//Retorna a area original do arquivo SD?...
	RestArea(aAreaSD)
Else
	//A factura nao foi encontrada no arquivo SF? correspondente...
	VerifErro(,@aDArq,"5",cNota,cSerie,cCliFor,cLoja,,(cAliasSF3)->F3_ESPECIE,cAliasSF)
EndIf

//Ativa o SET para nao visualizar mais a facturas ou notas canceladas...
If !Empty(dDtaCanc)
	SET DELETED ON
EndIf

//Retorna area original da entrada da rotina...
RestArea(aAreaSF)
RestArea(aAreaAtu)

Return Nil 

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ TotCat       ³Autor ³ Julio Cesar          ³Data³ 13/05/03 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Retorna o total de uma determinada informacao do imposto.  ³±± 
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function TotCat(nCatImp,cInf,aImps,cTpRet,nValMerc,aAliq,nAliq,lTot,lConvert)
//nCatImp 	=> Categoria do imposto (IVA,RNI,PIB)
//cInf 		=> 1-Base/2-Valor/3-Tot Aliq/4-Valor de Merc menos a base do imposto 
//cTpRet 	=> 1-String/2-Numerico                           
//nValMerc 	=> Valor total da mercadoria  
//aAliq     => Array com totas as aliquotas existentes em uma factura
//nAliq		=> Aliquota para qual esta sendo gerada a linha no arq. correspondente
//lTot      => Determina se soma o total da categ. independente da aliquota do imposto

Local cRet    := ""
Local nI   	  := 0
Local nX      := 0
Local nValAux := 0    
Local nDecimais := MsDecimais(1)

Default aAliq := {}
Default nAliq := 0
Default lTot  := .T.
Default lConvert:=.F.

If lTot
	For nI := 1 To Len(aImps)
		Do Case
			Case cInf == "1"
				For nX := 1 To Len(aImps[nI][nCatImp][3])
					nValAux += aImps[nI][nCatImp][3][nX][1]
				Next nX
				cRet := MontaValor(nValAux,"@E 9999999999999.99",15)							
			Case cInf == "2"                              
				For nX := 1 To Len(aImps[nI][nCatImp][3])
					nValAux += aImps[nI][nCatImp][3][nX][3]                      			
				Next nX
				cRet := MontaValor(nValAux,"@E 9999999999999.99",15)
			Case cInf == "3"   
				For nX := 1 To Len(aImps[nI][nCatImp][3])
					If aScan(aAliq,{|x| x == aImps[nI][nCatImp][3][nX][5]}) == 0
						AAdd(aAliq,aImps[nI][nCatImp][3][nX][5])
						nValAux++ 
					EndIf
				Next nX
			
				//Caso existam somente duas aliquotas de IVA e uma delas e 0(Zero) o total
				//de aliquotas eh igual a 1...
			 	If Len(aAliq) == 2
					If (nX := aScan(aAliq,{|x| x == 0})) > 0
						aDel(aAliq,nX)
						aSize(aAliq,Len(aAliq)-1)
						
						nValAux-- 
					EndIf
			 	EndIf

				cRet := MontaValor(nValAux,"9",1)
			Case cInf == "4"
				For nX := 1 To Len(aImps[nI][nCatImp][3])
					If nValAux == 0
						nValAux := nValMerc - aImps[nI][nCatImp][3][nX][1]
					Else
						nValAux -= aImps[nI][nCatImp][3][nX][1]
					EndIf
				Next nX		
				cRet := MontaValor(nValAux,"@E 9999999999999.99",15)
		EndCase
	Next nI
Else
	For nI := 1 To Len(aImps)
			Do Case
			Case cInf == "1"
				For nX := 1 To Len(aImps[nI][nCatImp][3])
					If aImps[nI][nCatImp][3][nX][5] == nAliq
						nValAux += aImps[nI][nCatImp][3][nX][1]
					EndIf
				Next nX
				cRet := MontaValor(nValAux,"@E 9999999999999.99",15)							
			Case cInf == "2"                        
				For nX := 1 To Len(aImps[nI][nCatImp][3])
					If aImps[nI][nCatImp][3][nX][5] == nAliq      
						nValAux += aImps[nI][nCatImp][3][nX][3]                      			
					EndIf
				Next nX
				cRet := MontaValor(nValAux,"@E 9999999999999.99",15)
			Case cInf == "4"
				For nX := 1 To Len(aImps[nI][nCatImp][3])
					If aImps[nI][nCatImp][3][nX][5] == nAliq
						If nValAux == 0
							nValAux := nValMerc - aImps[nI][nCatImp][3][nX][1]
						Else
							nValAux -= aImps[nI][nCatImp][3][nX][1]
						EndIf
					EndIf
				Next nX		
				cRet := MontaValor(nValAux,"@E 9999999999999.99",15)
		EndCase
	Next nI
EndIf
// O valor do Imposto deve estar sempre na moeda 1      
If lConvert
	nValAux:=Round(xMoeda(nValAux,nMoedaCor,1,dDtaDgt,nDecimais+1,nTaxaMoeda),nDecimais)
EndIf
Return(Iif(cTpRet="1",cRet,nValAux))

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ CriaArrayImp ³Autor ³ Julio Cesar          ³Data³ 13/05/03 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Cria o array que ira armazenar as informacoes dos impostos ³±±  
±±³          ³ conforme a sua categoria (IVA, RNI, PIB).                  ³±± 
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function CriaArrayImp()

//Sempre que valorizar o array aDImps eh necessario seguir a configuracao
//dos defines criados (IVA,RNI,PIB). Caso seja necessario aumente o numero
//de Defines.

//Dados referentes a categoria IVA
aDImps[IVA][1] := IVA
aDImps[IVA][2] := AllTrim(MV_PAR06) 
aDImps[IVA][3] := {}

//Dados referentes a categoria RNI (Responsable no Inscripto)
aDImps[RNI][1] := RNI
aDImps[RNI][2] := AllTrim(MV_PAR07) 
aDImps[RNI][3] := {}
                                  
//Dados referentes a categoria PIB (Percepcion de Ingreso Bruto)
aDImps[PIB][1] := PIB
aDImps[PIB][2] := AllTrim(MV_PAR08) 
aDImps[PIB][3] := {} 

//Dados referentes a categoria PIN (Percepcion de Impuestos Nacionales)
aDImps[PIN][1] := PIN
aDImps[PIN][2] := AllTrim(MV_PAR09) 
aDImps[PIN][3] := {}
                     
//Dados referentes a categoria PIM (Percepcion de Impuestos Municipales)
aDImps[PIM][1] := PIM
aDImps[PIM][2] := AllTrim(MV_PAR10) 
aDImps[PIM][3] := {}

//Dados referentes a categoria PII (Percepcion de Impuestos Internos)
aDImps[PII][1] := PII
aDImps[PII][2] := AllTrim(MV_PAR11) 
aDImps[PII][3] := {} 

//Dados referentes a categoria IVP (Percepcion del impuesto al valor agregado)
aDImps[IVP][1] := IVP
aDImps[IVP][2] := AllTrim(MV_PAR12) 
aDImps[IVP][3] := {}

Return Nil

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ PesqCodOp    ³Autor ³ Julio Cesar          ³Data³ 13/05/03 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Retorna qual e o tipo de operacao(X = Cliente do Exterior, ³±±  
±±³          ³ E = Isento, " " = Generico, Z = Exp. a Zona Franca)        ³±± 
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function PesqCodOp(nVlrOtrImp,nVlrIVA,cCliFor,cLoja,cAlias,cCat,nAliq,lNAlcIVA)
//nVlrOtrImp=> Valores que nao itegram a base de calculo do IVA
//nVlrIVA	=> Valor do IVA                    
//cCliFor	=> Codigo do Cliente/Fornecedor
//cLoja 	=> Codigo da loja do Cliente/Fornecedor
//cAlias	=> Determina se esta sendo pesquisado um cliente ou fornecedor
//cCat 		=> Categoria (1 = Verifica valor do IVA e outros impostos, 2 = Verifica Aliquota do IVA)             
//nAliq 	=> Aliquota do IVA
Local cTpOP   := ""
Local cCpoEst := SubStr(cAlias,2,2)+"_TIPO"

Default nVlrOtrImp := 0 
Default nAliq      := 0

If Iif(cCat == "1",nVlrIVA == 0 .And. nVlrOtrImp <> 0,nAliq == 0)
	//Caso seja um cliente/fornecedor do exterior o tipo eh igual a "X".
	//Caso nao seja do exterior podera ser um cliente isento "E" ou que realiza
	//exportacoes para a Zona Franca "Z".            
	cTpOP := Posicione(cAlias,1,xFilial(cAlias)+cCliFor+cLoja,cCpoEst)
	Do Case
		Case cTpOP == "E" // SA1-Deudores del Exterior || SA2-Exportacion
			cTpOP := "X"
		Case cTpOp == "X" // SA1-Exento || SA2-Exento
			cTpOP := "E"      
		Case cTpOp == "I"
			If lNAlcIVA
				cTpOP := "N"
			Else
				cTpOP := "E"
			EndIf      				
/*-Alteracao solicitada no bops 101237 - 07/06/2006-*/
		Case cTpOp == "S"
			cTpOp := "N"
/*--------------------------------------------------*/
		Case cTpOp == "M" .Or. cTpOp == "N"
			cTpOP := Space(01)		
		Case cTpOp <> "Z" // SA1-Exportaciones a la Zona Franca || SA2-Exportaciones a la Zona Franca
			cTpOP := "?"
	EndCase	
Else
	cTpOP := Space(01)
EndIf

Return(cTpOP)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³GeraOtrPercep ³Autor ³ Julio Cesar          ³Data³ 13/05/03 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Gera os dados e grava o arquivo OTRAS_PERCEP, referente aos³±±  
±±³          ³ impostos de ingresos brutos (PIB).                         ³±± 
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function GeraOtrPercep(aDArq,aDadosFac,aTES,aImps,cAlias)

Local cStr    := ""
Local cCFO    := ""
Local cProv   := ""
Local nI      := 0
Local nX      := 0
Local nCat    := 0
Local nPosCat := 0
Local nPosJur := 0
Local aTotJur := {}
Local aImpInf := {}
Local aCab    := {}               
Local nPosicao := 0
//Campos dos arquivos SF?
Local nSFDoc    := (cAlias)->(FieldPos(SubStr(cAlias,2,2)+"_DOC"))
Local nSFSer    := (cAlias)->(FieldPos(SubStr(cAlias,2,2)+"_SERIE"))
Local nSFCliFor := (cAlias)->(FieldPos(SubStr(cAlias,2,2)+Iif(cAlias == "SF2","_CLIENTE","_FORNECE")))
Local nSFLoja   := (cAlias)->(FieldPos(SubStr(cAlias,2,2)+"_LOJA"))
Local nSFEsp    := (cAlias)->(FieldPos(SubStr(cAlias,2,2)+"_ESPECIE"))

For nI := 1 To Len(aTES)
	cCFO    := Posicione('SF4',1,xFilial('SF4')+aTES[nI],'F4_CF')
	aImpInf := TesImpInf(aTES[nI])                                  

	For nX := 1 To Len(aImpInf)	     
		If AllTrim(aImpInf[nX][1])$aDImps[PIB][2]
			cProv   := PesqJurImp(aImpInf[nX][1],aTES[nI],cCFO)
			nPosCat := aScan(aDImps,{|x| Trim(aImpInf[nX][1])$Trim(x[2])})
			nCat    := aDImps[nPosCat][1]
			nPosJur := aScan(aTotJur,{|x| Trim(x[1]) == cProv})

			If nPosJur == 0 
				AAdd(aTotJur,Array(2))
				aTotJur[Len(aTotJur)][1] := cProv
				aTotJur[Len(aTotJur)][2] := {nCat,TotImp(cAlias,aImpInf[nX][01],"2","2",aImpInf)}       
			Else
				nPosCat := aScan(aTotJur[nPosJur],{|x| x[1] == nCat}, 2)
				If nPosCat <> 0
					aTotJur[nPosJur][nPosCat][2] += TotImp(cAlias,aImpInf[nX][01],"2","2",aImpInf)
				Else 
					AAdd(TotJur[nPosJur],{nCat,TotImp(cAlias,aImpInf[nX][01],"2","2",aImpInf)})
				EndIf
			EndIf
		EndIf
	Next nX				
Next nI

For nI := 1 To Len(aTotJur)
	AAdd(aCab,aDadosFac[02])	//Campo 1 - Data do Comprovante
	AAdd(aCab,aDadosFac[03])	//Campo 2 - Tipo do Comprovante
	AAdd(aCab,aDadosFac[05])	//Campo 3 - Ponto de Venda
	AAdd(aCab,aDadosFac[06])	//Campo 4 - Numero do Comprovante

	//Os dados do campo 5 ate o campo 8 variam conforme a Jurisdicao e a categoria (PIB ou PIM)
	//Ingresos Brutos
	If (nPosCat := aScan(aTotJur[nI],{|x| x[1] == PIB}, 2)) > 0       
  		AAdd(aCab,PesqJurCliFor(aTotJur[nI][1],"1"))	//Campo 5 - Jurisdicao (Provincia) dos Ingresos Brutos
		AAdd(aCab,MontaValor(aTotJur[nI][nPosCat][2],"@E 9999999999999.99",15))	//Campo 6 - Valor total de Ingresos Brutos
	Else 
		AAdd(aCab,"00")
		AAdd(aCab,Replicate("0",15))  
	EndIf                               
	                                                  
	//Impostos Municipais
	If (nPosCat := aScan(aTotJur[nI],{|x| x[1] == PIM}, 2)) > 0       
     	nPosicao := nPosCat	
		AAdd(aCab,PesqJurCliFor(aTotJur[nI][1],"2"))	//Campo 7 - Jurisdicao (Provinvia) dos Impostos Municipais
		AAdd(aCab,MontaValor(aTotJur[nI][nPosCat][2],"@E 9999999999999.99",15))	//Campo 8 - Valor total dos impostos municipais 
	Else
		AAdd(aCab,Space(40))
		AAdd(aCab,Replicate("0",15))          
		nPosicao := 2
	EndIf     
	
    If aTotJur[nI][nPosicao][2] <> 0    	
  	  //Gera Linha que sera gravada no arquivo OTRAS_PERCEP 
	  aEval(aCab,{|x| cStr += x})
	  cStr += Chr(13)+Chr(10)	

	//Executa funcao que verifica possiveis erros na geracao dos dados...
	VerifErro(aCab,@aDArq,"3",FieldGet(nSFDoc),FieldGet(nSFSer),FieldGet(nSFCliFor),FieldGet(nSFLoja),,FieldGet(nSFEsp),cAlias)
	
	//Grava linha no arquivo no arquivo de itens...
	TrabArqTxt(.F.,@aDArq,OTR_PERCEP,aDArq[OTR_PERCEP][1],aDArq[OTR_PERCEP][2],cStr)	
   EndIf	
	//Limpa variaveis utilizadas
	cStr := ""
	aCab := {}
Next nI

Return Nil                     

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³PesqJurCliFor ³Autor ³ Julio Cesar          ³Data³ 13/05/03 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Retorna o codigo de jurisdicao do cliente/fornecedor que   ³±±  
±±³          ³ devera ser gravado no arquivo OTRAS_PERCEP.                ³±± 
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function PesqJurCliFor(cJur,cTpJur)
//cJur     	=> Codigo da Jurisdicao   
//cTpJur	=> Tipo de Jurisdicao (1-Codigo/2-Descricao)
      
Local aAreaAtu:= {}
Local aAreaSX5:= {}

aAreaAtu := GetArea() 
dbSelectArea("SX5")
aAreaSX5 := GetArea()
dbSetOrder(1)
If dbSeek(xFilial("SX5")+"OE"+cJur)
	Do Case 
		Case cTpJur == "1"
			cJur := SubStr(X5DESCRI(),1,2)
		Case cTpJur == "2"
			cJur := SubStr(X5DESCRI(),4,40)
	EndCase
EndIf
RestArea(aAreaSX5)
RestArea(aAreaAtu)

Return(cJur)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³TotImpCat 	³Autor ³ Julio Cesar          ³Data³ 13/05/03 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Retorna o total da base dos impostos ou do valor dos       ³±±  
±±³          ³ impostos para uma determinada categoria.                   ³±± 
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function TotImp(cAlias,cImp,cTpRet,cInf,aImpInf)
//cAlias	=> Arquivo do qual serao retirados os totais
//cImp 		=> Codigo do imposto que se deseja obter o total
//cTpRet	=> Determina o tipo de retorno (1-String/2-Numerico)
//cInf      => Determina do que se quer obter o total (1-Base/2-Valor)
//aImpInf	=> Array que contem as informacoes dos Impostos

Local nI      := aScan(aImpInf,{|x| Trim(x[1])==Trim(cImp)})
Local nValAux := 0
Local cRet    := ""
Local cCpo    := ""

If nI <> 0
	Do Case
		Case cInf == "1"
			cCpo := SubStr(cAlias,2,2)+SubStr(aImpInf[nI][8],3,8)
		Case cInf == "2"                                             
			cCpo := SubStr(cAlias,2,2)+SubStr(aImpInf[nI][6],3,8)
	EndCase
	nValAux := (cAlias)->&cCpo.
EndIf
cRet := MontaValor(nValAux,"@E 9999999999999.99",15)

Return(Iif(cTpRet=="1",cRet,nValAux))

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³CgfDesLivr 	³Autor ³ Julio Cesar          ³Data³ 13/05/03 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Retorna o conteudo que sera gravado no campo de desenho    ³±±  
±±³          ³ livre.                                                     ³±± 
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function CgfDesLivr(dDtaCanc,cAlias)
               
Local cDesLvr  := ""
Local cCpoProd := SubStr(cAlias,2,2)+"_COD"
Local aAreaAtu := {}
Local aAreaSB1 := {}

If !Empty(dDtaCanc)
	cDesLvr := AllTrim((cAliasSF3)->F3_OBSERV)+" | "+Alltrim((cAliasSF3)->F3_OBSERV2)+" | "+AllTrim((cAliasSF3)->F3_OBSERV3)
Else
	aAreaAtu := GetArea()
	dbSelectArea("SB1")
	aAreaSB1 := GetArea()
	dbSetOrder(1)
	dbSeek(xFilial("SB1")+(cAlias)->&cCpoProd.)
	cDesLvr := AllTrim(SB1->B1_COD)+" | "+AllTrim(SB1->B1_DESC)
	RestArea(aAreaSB1)
	RestArea(aAreaAtu)	
EndIf
cDesLvr := Padr(cDesLvr,75," ")

Return(cDesLvr)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³UltDiaMes 	³Autor ³ Julio Cesar          ³Data³ 13/05/03 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Retorna o ultimo dia valido para um determinado mes.       ³±±  
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function UltDiaMes()

Local cUltDia    := ""
   
Do Case
	Case cMes$("01|03|05|07|08|10|12")
		cUltDia := "31"
	Case cMes$("04|06|09|11")
		cUltDia := "30"
	OtherWise
		If Day(Ctod(cMes+"/29/"+MV_PAR01)) == 0
			cUltDia := "28"
		Else
			cUltDia := "29"
		EndIf
EndCase

Return(cUltDia)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³PesqJurImp 	³Autor ³ Julio Cesar          ³Data³ 13/05/03 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Retorna a jurisdicao de um determinado impostos (PIB)      ³±±  
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function PesqJurImp(cImp,cTES,cCFO)

Local cJurImp := ""
Local nIndex  := Iif(cTES <= "500",5,6)
Local aAreaAtu:= GetArea()
Local aAreaSFF:= {}

dbSelectArea("SFF")
aAreaSFF := GetArea()
dbSetOrder(nIndex)
If dbSeek(xFilial("SFF")+cImp+cCFO)
	cJurImp := SFF->FF_ZONFIS
EndIf
RestArea(aAreaSFF)
RestArea(aAreaAtu)

Return(cJurImp)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³GrvDadosImp 	³Autor ³ Julio Cesar          ³Data³ 13/05/03 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Grava os dados referente a factura de importacao.          ³±±  
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function GrvDadosImp(aCab,cDesp,cTipoNF)
                   
Local aAreaAtu := GetArea()
Local aAreaSW6 := {}
Local cCodAdu  := ""                                          
Local cCodDest := ""
Local cDigVer  := ""
Local cDtaOfi  := ""
Local cNumDesp := ""
Local nTam     := 0
               
dbSelectArea("SW6")
aAreaSW6 := GetArea()
dbSetOrder(1)
If dbSeek(xFilial("SW6")+cDesp)
	cDtaOfi  := Dtos(SW6->W6_DTREG_D)

	//Determina o numero do despacho, para que as informacoes possam ser tratadas...

	//Alteracoes referentes ao BOPS 94175
	If cTipoNF == "9" .And. SW6->W6_CURRIER == "1"  //Sim
		cDesp := Replicate("0",3)			//Campo 08 - Codigo de Aduana
		cDesp += Space(4)   				//Campo 09 - Codigo de Destino
		cDesp += Replicate("0",6)			//Campo 10 - Numero de Despacho
		cDesp += Space(1)					//Campo 11 - Digito verificador do numero do despacho
	Else
		//cDesp := AllTrim(SW6->W6_HAWB)
		cDesp := AllTrim(SW6->W6_DI_NUM)
	Endif

	nTam  := Len(cDesp)

	//Essas informacoes possuem tamanho fixo...
	cDigVer  := Right(cDesp,1)				//Digito Verificador
	cNumDesp := SubStr(cDesp,nTam -  6,6)	//Numero do Despacho
	cCodDest := SubStr(cDesp,nTam - 10,4) 	//Codigo de Destino
	cCodAdu  := SubStr(cDesp,nTam - 13,3) 	//Codigo da Aduana
    
	//Gerar codigo para que os dados da importacao sejam gravados corretamente.
	aCab[02] := cDtaOfi	//Campo 02 - Data de Oficializacao
	AAdd(aCab,cCodAdu) 	//Campo 08 - Codigo de Aduana
	AAdd(aCab,cCodDest)	//Campo 09 - Codigo de Destino
	AAdd(aCab,cNumDesp)	//Campo 10 - Numero de Despacho
	AAdd(aCab,cDigVer)	//Campo 11 - Digito verificador do numero do despacho
EndIf
RestArea(aAreaSW6)
RestArea(aAreaAtu)

Return Nil

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³fImpsMta991 	³Autor ³ Julio Cesar          ³Data³ 13/05/03 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Permite que o usuario determine um ou mais impostos a uma  ³±±  
±±³          ³ determinada categoria de imposto, no momento en que sao    ³±±   
±±³          ³ valorizados os parametros.                                 ³±±  
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/                                                                
Function fImpsMta991(cCat)

	Local oWnd  := GetWndDefault()
	Local MvPar := &(Alltrim(ReadVar())) // Carrega Nome da Variavel do Get em Questao
	Local MvRet := Alltrim(ReadVar())	  // Iguala Nome da Variavel ao Nome variavel de Retorno
	Local cRet  := MvPar
	
	Default cCat := ""
	
	Do Case
		Case cCat == "1"
	    	cCat := OemToAnsi(STR0019) //Impostos IVA
	 	Case cCat == "2"
	    	cCat := OemToAnsi(STR0020) //Impostos RNI
	 	Case cCat == "3"
	    	cCat := OemToAnsi(STR0021) //Ingressos Brutos
	 	Case cCat == "4"
	    	cCat := OemToAnsi(STR0022) //Impostos Nacionais
	 	Case cCat == "5"
	    	cCat := OemToAnsi(STR0023) //Impostos Municipais
	 	Case cCat == "6"
	    	cCat := OemToAnsi(STR0024) //Impostos Internos
	 	Case cCat == "7"
	    	cCat := OemToAnsi(STR0063) //Percepcion del IVA
	EndCase
	
	//Executa funcao que ira montar o ListBox e tratar o retorno...
	fLstBoxImps(@cRet)
	If AllTrim(MvPar) <> AllTrim(cRet)
		If !MsgYesNo(OemToAnsi(STR0013)+cCat+" ?") //"Confirma a alteracao dos impostos que compoem a categoria "
			Return(.T.)
		EndIf
		&MvRet := AllTrim(cRet)
	EndIf

Return .T.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³fLstBoxImps 	³Autor ³ Julio Cesar          ³Data³ 13/05/03 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Monta o ListBox no qual serao exibidos os impostos que     ³±±  
±±³          ³ poderao ser selecionados pelo usuario.                     ³±±   
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/                                                                
Static Function fLstBoxImps(cRet) 

	Local oDlg			:= Nil
	Local oMain			:= Nil
	Local oListBox		:= Nil       
	Local oBtnMarcTod	:= Nil
	Local oBtnDesmTod	:= Nil
	Local oBtnInverte	:= Nil
	Local oOk			:= LoadBitmap( GetResources(), "LBOK" )
	Local oNo			:= LoadBitmap( GetResources(), "LBNO" )
	Local aListBox		:= {}
	Local aAreaSFB		:= GetArea()
	Local aAreaAtu		:= GetArea()
	Local cVarQ			:= ""
	Local nOpca			:= 0
	Local bNIL			:= { || NIL }
	Local bSvSet15		:= bNIL
	Local bSvSet24		:= bNIL
	Local bSvVK_F4		:= bNIL
	Local bSvVK_F5		:= bNIL
	Local bSvVK_F6		:= bNIL
	Local cFilSFB		:= xFilial("SFB")
	
	Default cRet := ""
	
	dbSelectArea("SFB")
	aAreaSFB := GetArea()
	SFB->(dbSetOrder(1))
	SFB->(dbGoTop())
	While !SFB->(Eof()) .AND. SFB->FB_FILIAL == cFilSFB
		AAdd(aListBox,{.F., SFB->FB_CODIGO + " - " + SFB->FB_DESCR})
		If SFB->FB_CODIGO $ cRet
			aListBox[Len(aListBox)][1] := .T.
		EndIf
		SFB->(dbSkip())
	End
	RestArea(aAreaSFB)
	RestArea(aAreaAtu)
	
	nLin1 := 15.00
	nCol1 := 02.00
	
	DEFINE MSDIALOG oDlg TITLE OemToAnsi(STR0014) FROM 026,043 TO 273,482 OF oMain PIXEL //"Selecao de Impostos"
	
	@ nLin1,nCol1 LISTBOX oListBox VAR cVarQ FIELDS HEADER "",OemToAnsi(STR0015) SIZE 217,093; //"Imposto"
	ON DBLCLICK (MrkLstBox(@aListBox,@oListBox,oListBox:nAt,oOk,oNo,"N")) NOSCROLL PIXEL
	oListBox:SetArray(aListBox)
	oListBox:bLine := { || { IF(aListBox[oListBox:nAt,1],oOk,oNo),aListBox[oListBox:nAt,2] } }	
	
	@ 110,001.00 BUTTON oBtnMarcTod	PROMPT OemToAnsi(STR0016) SIZE 64.50,13.50 OF oDlg	PIXEL ACTION (MrkLstBox(@aListBox,@oListBox,oListBox:nAt,oOk,oNo,"M")) //"Marca Todos - <F4>"
	bSvVK_F4 := SetKey(VK_F4,{ || (MrkLstBox(@aListBox,@oListBox,oListBox:nAt,oOk,oNo,"M")) } )
	@ 110,077.50 BUTTON oBtnDesmTod	PROMPT OemToAnsi(STR0017) SIZE 64.50,13.50 OF oDlg	PIXEL ACTION (MrkLstBox(@aListBox,@oListBox,oListBox:nAt,oOk,oNo,"D")) //"Desmarca Todos - <F5>"
	bSvVK_F6 := SetKey(VK_F5,{ || (MrkLstBox(@aListBox,@oListBox,oListBox:nAt,oOk,oNo,"D")) } )
	@ 110,155.50 BUTTON oBtnInverte	PROMPT OemToAnsi(STR0018) SIZE 64.50,13.50 OF oDlg	PIXEL ACTION (MrkLstBox(@aListBox,@oListBox,oListBox:nAt,oOk,oNo,"I")) //"Inverte Sele‡„o - <F6>"
	bSvVK_F6 := SetKey(VK_F6,{ || (MrkLstBox(@aListBox,@oListBox,oListBox:nAt,oOk,oNo,"I")) } )
	
	bSvSet15 := SetKey( 15 , oDlg:bSet15 )
	bSvSet24 := SetKey( 24 , oDlg:bSet24 )
	
	ACTIVATE MSDIALOG oDlg CENTERED ON INIT EnchoiceBar( oDlg , { || nOpca := 1 , oDlg:End() } , { || nOpca := 0 , oDlg:End() } )
	
	SetKey( 15		,	IF( Empty( bSvSet15 ) , bNIL , bSvSet15 ) )
	SetKey( 24		,	IF( Empty( bSvSet24 ) , bNIL , bSvSet24 ) )
	SetKey( VK_F4	,	IF( Empty( bSvVK_F4 ) , bNIL , bSvVK_F4 ) )
	SetKey( VK_F5	,	IF( Empty( bSvVK_F5 ) , bNIL , bSvVK_F5 ) )
	SetKey( VK_F6	,	IF( Empty( bSvVK_F6 ) , bNIL , bSvVK_F6 ) )
	
	If nOpca == 1
		cRet := ""
		aEval(aListBox,{|x,y| cRet += Iif(x[1],SubStr(x[2],1,3)+"|","")})
		cRet := SubStr(cRet,1,Len(cRet)-1)
	EndIf
	
	DeleteObject(oOk)
	DeleteObject(oNo)

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³MrkLstBox 	³Autor ³ Julio Cesar          ³Data³ 13/05/03 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Realiza a marca/desmarca dos itens do ListBox.             ³±±  
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/                                                                
Static Function MrkLstBox(aListBox,oListBox,nI,oOk,oNo,cAct)
        
Local nX := 0

Do Case 
	Case cAct == "N"
		If aListBox[nI][1] == .T.
			aListBox[nI][1] := .F.
		Else
			aListBox[nI][1] := .T.
		EndIf
	Case cAct == "M"
		For nX := 1 To Len(aListBox)
			aListBox[nX][1] := .T.		
		Next nX
	Case cAct == "D"
		For nX := 1 To Len(aListBox)
			aListBox[nX][1] := .F.		
		Next nX		
	Case cAct == "I"		
		For nX := 1 To Len(aListBox)
			aListBox[nX][1] := !aListBox[nX][1]
		Next nX
EndCase		
	
oListBox:SetArray(aListBox)
oListBox:bLine := { || { IF(aListBox[oListBox:nAt,1],oOk,oNo),aListBox[oListBox:nAt,2] } }
oListBox:Refresh()

Return Nil

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³VerifErro 	³Autor ³ Julio Cesar          ³Data³ 13/05/03 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Cria um arquivo .log com os erros encontrados durante a    ³±±   
±±³          ³ geracao dos arquivos TXT.                                  ³±±  
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/                                                                
Static Function VerifErro(aDados,aDArq,cTipo,cNota,cSerie,cCliFor,cLoja,;
                          lIsento,cEspecie,cAlias,lUltimo,lRG1415)
                          
//aDados	=> Dados que serao gravados no arquivo
//aDArq	    => Array que contem os dados "fisicos" do arquivo texto a ser gerado                 
//cTipo		=> Tipo do arquivo (1 => Facturas Emitidas, 2 => Compras, 3 => Vendas)
//cNota		=> Numero do documento
//cSerie	=> Serie do Documento
//cCliFor 	=> Codigo do Cliente ou Fornecedor
//cLoja		=> Loja do Cliente ou Fornecedor
//lIsento	=> Determina se a venda foi isenta de IVA (.T. Sim, .F. Nao)
//cEspecie 	=> Especie da Factura
//cAlias	=> Alias do arquivo que esta sendo verificado
//lUltimo	=> Determina se eh a ultima linha gerada referente a um registro do arquivo
        
Local aCab     	:= {}
Local aInf     	:= {}
Local aAreaAtu 	:= GetArea()
Local aAreaSX5 	:= {}
Local cStr     	:= ""
Local cGrupo   	:= ""
Local cErro    	:= ""
Local lErro    	:= .F.
Local nI       	:= 0
Local lVldCAI	:=.T.
Local aAlias	:={}
Local aAliasSA2	:={}
Default lUltimo := .T.

//Determina a especie da factura
cEspecie := GetSesNew(AllTrim(cEspecie),Iif(cAlias$"SD2|SF2","1","2"))
cEspecie := cEspecie+Space(TAMSX3("X5_CHAVE")[1]-Len(cEspecie))

//Busca o nome do documento, conforme a especie
dbSelectArea("SX5")
aAreaSX5 := GetArea()
dbSetOrder(1)
If dbSeek(xFilial("SX5")+"05"+cEspecie)
	cEspecie := SubStr(X5DESCRI(),1,18)
Else
	cEspecie := OemToAnsi(STR0058)+Space(18-Len(STR0058))
EndIf
RestArea(aAreaSX5)
RestArea(aAreaAtu)

If !lTab 
	AAdd(aCab,"|-----------------------------------------------------------------|")
	AAdd(aCab,STR0048)	//"|                          Tabla de Grupos                        |" 
	AAdd(aCab,"|-----------------------------------------------------------------|") 
	AAdd(aCab,STR0049)	//"| FACTS => Facturas emitidas/ventas                               |" 
	AAdd(aCab,STR0050)	//"| COMPR => Compras                                                |" 
	AAdd(aCab,STR0051)	//"| PERC  => Otras Percepciones                                     |"
	AAdd(aCab,STR0059)	//"| VENTA => Ventas                                                 |" 
	AAdd(aCab,STR0062)	//"| GENE  => General (Registro no encontrado en el archivo)         |"
	AAdd(aCab,"|=================================================================|")
	AAdd(aCab,STR0031)	//"|                          Tabla de Errores                       |" 
	AAdd(aCab,"|-----------------------------------------------------------------|") 
	AAdd(aCab,STR0032)	//"| 01 => Tipo de Comprobante Invalido                              |" 
	AAdd(aCab,STR0033)	//"| 02 => Codigo del Documento Identificatorio Invalido             |"
	AAdd(aCab,STR0034) 	//"| 03 => Numero del Documento Identificatorio Invalido             |"
	AAdd(aCab,STR0035)	//"| 04 => Nome del Cliente/Proveedor Invalido                       |"
	AAdd(aCab,STR0036)	//"| 05 => Codigo del Tipo del Cliente/Proveedor Invalido            |" 
	AAdd(aCab,STR0037)	//"| 06 => Codigo de la Operacion Invalido                           |" 
	AAdd(aCab,STR0038)	//"| 07 => Numero del CAI Invalido                                   |"
	AAdd(aCab,STR0039)	//"| 08 => Punto de Venta Invalido para el tipo de Cliente/Proveedor |"  
	AAdd(aCab,STR0040)	//"| 09 => Importe total de la operacion es invalido                 |"  
	AAdd(aCab,STR0041)	//"| 10 => Importe neto gravado invalido                             |" 
	AAdd(aCab,STR0042)	//"| 11 => Impuesto Liquidado invalido                               |"  
	AAdd(aCab,STR0043)	//"| 12 => Impuesto Liquidado a RNI invalido                         |"  
	AAdd(aCab,STR0044)	//"| 13 => Codigo de la moneda invalido                              |" 
	AAdd(aCab,STR0045)	//"| 14 => Codigo de Jurisdiccion Invalido                           |" 
	AAdd(aCab,STR0046)	//"| 15 => Valor de Ingresos Brutos Invalido                         |" 
	AAdd(aCab,STR0047)	//"| 16 => Valor de Impostos Municipais Invalidos                    |" 	
	AAdd(aCab,STR0060)	//"| 17 => Factura no encontrada en el archifo SF?                   |" 	
	AAdd(aCab,STR0061)	//"| 18 => Factura no encontrada en el archifo SD?                   |" 	
	AAdd(aCab,STR0064)	//"| 19 => Fecha del vencimiento del CAI Vacia                       |" 	
	AAdd(aCab,"|=================================================================|") 
	AAdd(aCab,"") 
	AAdd(aCab,STR0054)  //"Ocurrencias : "
	AAdd(aCab,"") 
	AAdd(aCab,"|-----------------------------------------------------------------------|") 
	AAdd(aCab,STR0055)  //"|Error|Grupo|Alias|Documento         |Numero      |Serie|Cli/Prov|Tienda|"
	AAdd(aCab,"|-----|-----|-----|------------------|------------|-----|--------|------|")
EndIf

//Grava linha no arquivo...
If lErro
	For nI := 1 To Len(aCab)
		cStr := aCab[nI]+chr(13)+Chr(10)
		//Grava linha no arquivo no arquivo de itens...
		TrabArqTxt(.F.,@aDArq,LOG_ERROS,aDArq[LOG_ERROS][1],aDArq[LOG_ERROS][2],cStr)	
	Next nI
EndIf

Do Case
	Case cTipo == "1"                                                            
		cGrupo := OemToAnsi("FACTS")
		AAdd(aInf,aDados[03])	//Campo 01 - Tipo de Comprovante
		AAdd(aInf,aDados[09])	//Campo 02 - Codigo do Documento de Identificacao
		AAdd(aInf,aDados[10])	//Campo 03 - Numero do Documento de Identificacao
		AAdd(aInf,aDados[11])	//Campo 04 - Nome do Cliente/Fornecedor
		AAdd(aInf,aDados[23])	//Campo 05 - Tipo do Cliente/Fornecedor 
		AAdd(aInf,aDados[27])	//Campo 06 - Codigo da Operacao
		AAdd(aInf,aDados[28])	//Campo 07 - CAI 
		AAdd(aInf,aDados[05])	//Campo 08 - Ponto de Venda
		AAdd(aInf,aDados[12])	//Campo 09 - Valor Total da Operacao
		AAdd(aInf,aDados[14])	//Campo 10 - Base Total do IVA
		AAdd(aInf,aDados[15])	//Campo 11 - Valor do IVA
		AAdd(aInf,aDados[16])	//Campo 12 - Imposto sobre RNI			
		AAdd(aInf,aDados[24])	//Campo 13 - Codigo da Moeda
		AAdd(aInf,aDados[29])	//Campo 14 - Vencimento do CAI
		AAdd(aInf,aDados[02])	//Campo 15 - Controlador Fiscal
		AAdd(aInf,aDados[30])	//Campo 16 - Data de cancelamento
	Case cTipo == "2"
		cGrupo := OemToAnsi("COMPR")
		AAdd(aInf,aDados[03])	//Campo 01 - Tipo de Comprovante
		AAdd(aInf,aDados[12])	//Campo 02 - Codigo do Documento de Identificacao
		AAdd(aInf,aDados[13])	//Campo 03 - Numero do Documento de Identificacao
		AAdd(aInf,aDados[14])	//Campo 04 - Nome do Cliente/Fornecedor
		AAdd(aInf,aDados[26])	//Campo 05 - Tipo do Cliente/Fornecedor 
		AAdd(aInf,aDados[30])	//Campo 06 - Codigo da Operacao
		AAdd(aInf,aDados[31])	//Campo 07 - CAI 
		AAdd(aInf,aDados[05])	//Campo 08 - Ponto de Venda
		AAdd(aInf,aDados[15])	//Campo 09 - Valor Total da Operacao
		AAdd(aInf,aDados[17])	//Campo 10 - Base Total do IVA
		AAdd(aInf,aDados[19])	//Campo 11 - Valor do IVA
		AAdd(aInf,"")			//Campo 12 - Imposto sobre RNI			
		AAdd(aInf,aDados[27])	//Campo 13 - Codigo da Moeda
		AAdd(aInf,aDados[32])	//Campo 14 - Vencimento do CAI
		AAdd(aInf,aDados[04])	//Campo 15 - Controlador Fiscal
		AAdd(aInf,"000000000")	//Campo 15 - Controlador Fiscal
	Case cTipo == "3"                                                            
		cGrupo := OemToAnsi("PERC ")
		AAdd(aInf,aDados[02])	//Campo 01 - Tipo de Comprovante
		AAdd(aInf,aDados[05])	//Campo 02 - Codigo da Jurisdicao dos IB 
		AAdd(aInf,aDados[06])	//Campo 03 - Valor Total de IB 
		AAdd(aInf,aDados[07])	//Campo 04 - Jurisdicao de Impostos Municipais 
		AAdd(aInf,aDados[08])	//Campo 05 - Valor Total de Impostos Municipais
	Case cTipo == "4"                                                            
		cGrupo := OemToAnsi("VENTA")
		AAdd(aInf,aDados[03])	//Campo 01 - Tipo de Comprovante
		AAdd(aInf,aDados[08])	//Campo 02 - Codigo do Documento de Identificacao
		AAdd(aInf,aDados[09])	//Campo 03 - Numero do Documento de Identificacao
		AAdd(aInf,aDados[10])	//Campo 04 - Nome do Cliente/Fornecedor
		AAdd(aInf,"")			//Campo 05 - Tipo do Cliente/Fornecedor 
		AAdd(aInf,aDados[26])	//Campo 06 - Codigo da Operacao
		AAdd(aInf,aDados[27])	//Campo 07 - CAI 
		AAdd(aInf,aDados[05])	//Campo 08 - Ponto de Venda
		AAdd(aInf,aDados[11])	//Campo 09 - Valor Total da Operacao
		AAdd(aInf,aDados[13])	//Campo 10 - Base Total do IVA
		AAdd(aInf,aDados[15])	//Campo 11 - Valor do IVA
		AAdd(aInf,aDados[16])	//Campo 12 - Imposto sobre RNI			
		AAdd(aInf,aDados[23])	//Campo 13 - Codigo da Moeda
		AAdd(aInf,aDados[28])	//Campo 14 - Vencimento do CAI
		AAdd(aInf,aDados[04])	//Campo 15 - Controlador Fiscal
		AAdd(aInf,aDados[29])	//Campo 16 - Data de cancelamento
	OtherWise
		cGrupo := OemToAnsi("GENE ")
EndCase

//Cria linha que sera gravada no arquivo de log...
cErro :=cGrupo+"|"+cAlias+"  |"+cEspecie+"|"+cNota+"|"+cSerie+"  |"+cCliFor+"  |"+cLoja+"    |"

//Tipo de Comprovante Invalido
If cTipo$"1|2|3|4" .And. Empty(aInf[01]) 
	AAdd(aCab,"|01   |"+cErro) //"Erro "
	lErro := .T.
EndIf 
               
//Nao realiza essas verificacoes para IB
Do Case
	Case cTipo$"1|2|4"
		//Cod. do documento de Identificacao	
		If aInf[02] == "??"
			AAdd(aCab,"|02   |"+cErro) //"Erro "
			lErro := .T.
		EndIf	 
			
		//Num. documento de Identificacao	
		If Val(aInf[03]) == 0 .And. aInf[02] <> Space(02)
			AAdd(aCab,"|03   |"+cErro) //"Erro "
			lErro := .T.
		EndIf		 
			
		//Nome do Cliente/Fornecedor
		If Empty(aInf[04])
			AAdd(aCab,"|04   |"+cErro) //"Erro "
			lErro := .T.
		EndIf		 
			
		//Tipo do Cliente/Fornecedor
		If cTipo <> "4" .And. Empty(aInf[05])
			AAdd(aCab,"|05   |"+cErro) //"Erro "
			lErro := .T.
		EndIf		 
			
		//Codigo da Operacao
		If aInf[06] == "?"
			AAdd(aCab,"|06   |"+cErro) //"Erro "
			lErro := .T.		
		EndIf		 
			
		//CAI - So eh invalido quando for igual a zero e nao se trata de Cupom Fiscal.. 
		If (Empty(aInf[15]) .And. DToS((cAliasSF3)->F3_ENTRADA) >= SubStr(SuperGetMV("MV_DTACAI",,"20040101|20050101"),01,08)) .Or.;
           (!Empty(aInf[15]) .And. DToS((cAliasSF3)->F3_ENTRADA) >= SubStr(SuperGetMV("MV_DTACAI",,"20040101|20050101"),10,08)) 
            aAlias:=GetArea()
            aAliasSA2:=SA2->(GetArea())
            DbSelectArea("SA2")
            DbSetOrder(1)
            lVldCAI:=.T.
			If cTipo == "2" 
				
				If SA2->(DbSeek(xFilial("SA2")+ cCliFor+cLoja)) .And. SA2->A2_OBRICAI<>"1"
					lVldCAI:=.F.
				EndIf
			EndIf
			
			RestArea(aAlias)
            SA2->(RestArea(aAliasSA2))
			
			If Val(aInf[07]) == 0 .And. !(aInf[01]$"34|35|36|39|40|41") 
				SX5->(DbSetOrder(1))
				// So e obrigatorio quando forn/cliente e resp. inscrito
				If SX5->(MSSeek(xFilial("SX5")+"OD"+"I")) .And. aInf[05] == SubStr(SX5->(X5DESCRI()),1,2) .And. lVldCAI
					AAdd(aCab,"|07   |"+cErro) //"Erro "
					lErro := .T.		
				Endif
			EndIf		
			//Data de venciomento de CAI - So eh invalido quando for vazio e nao se trata de Cupom Fiscal.. 
			If Val(aInf[14])==0 .And. !(aInf[01]$"34|35|36|39|40|41") 
				SX5->(DbSetOrder(1))
				// So e obrigatorio quando forn/cliente e resp. inscrito
				If SX5->(MSSeek(xFilial("SX5")+"OD"+"I")) .And.	aInf[05] == SubStr(SX5->(X5DESCRI()),1,2)  .And. lVldCAI
					AAdd(aCab,"|19   |"+cErro) //"Erro "
					lErro := .T.		
				Endif
			EndIf		
		EndIf
		
		//Ponto de Venda
		If !lRG1415
			If aInf[05] == "01" .And. (aInf[08] < "0001" .Or. aInf[08] >= "9999")
				AAdd(aCab,"|08   |"+cErro) //"Erro "
				lErro := .T.		
			Else
				If (aInf[08] < "0000" .Or. aInf[08] >= "9999")
					AAdd(aCab,"|08   |"+cErro) //"Erro "
					lErro := .T.
				EndIf	
			EndIf	
		EndIf		
		
		//Valor Total da Operacao
		If aInf[09] == 0 .And. lUltimo .And. Empty(aInf[16])
			AAdd(aCab,"|09   |"+cErro) //"Erro "
			lErro := .T.
		EndIf		 
		
		//Total da Base de IVA
	 	If Empty(aInf[16])
			If (aInf[10] > aInf[09] .And. lUltimo) .Or.;
			   (aInf[10] < aInf[11]) .Or.;
			   (aInf[10] == 0 .And. (!lIsento .And. !(aInf[06]$"X|E|Z")))
	
				AAdd(aCab,"|10   |"+cErro) //"Erro "
				lErro := .T.
			EndIf		 
		EndIf		 
		
		//Valor do IVA
		If aInf[11] == 0 .And. aInf[10] <> 0
			AAdd(aCab,"|11   |"+cErro) //"Erro "
			lErro := .T.
		EndIf		 
		
		If cTipo == "1"
			//Imposto sobre RNI
			If aInf[05]$"02|07" .And. aInf[12] == 0
				AAdd(aCab,"|12   |"+cErro) //"Erro "
				lErro := .T.
			EndIf
		EndIf
			
		//Codigo da Moeda
		If Empty(aInf[13])
			AAdd(aCab,"|13   |"+cErro) //"Erro "
			lErro := .T.
		EndIf		 
	Case cTipo$"3"
		//Codigo de Jurisdicao de IB
		If Empty(aInf[02]) 
			AAdd(aCab,"|14   |"+cErro) //"Erro "
			lErro := .T.
		EndIf 
		
		//Valor de IB
		If Val(aInf[03]) == 0 .And. !Empty(aInf[02])
			AAdd(aCab,"|15   |"+cErro) //"Erro "
			lErro := .T.
		EndIf 
	
		//Valor de Impostos Municipais
		If Val(aInf[05]) == 0 .And. !Empty(aInf[04])
			AAdd(aCab,"|16   |"+cErro) //"Erro "
			lErro := .T.
		EndIf 
	Case cTipo$"5"                              
		AAdd(aCab,"|17   |"+cErro) //"Erro "
		lErro := .T.
	Case cTipo$"6"  
		AAdd(aCab,"|18   |"+cErro) //"Erro "
		lErro := .T.
EndCase

//Grava linha no arquivo...
If lErro
	For nI := 1 To Len(aCab)
		cStr := aCab[nI]+CRLF
		//Grava linha no arquivo no arquivo de itens...
		TrabArqTxt(.F.,@aDArq,LOG_ERROS,aDArq[LOG_ERROS][1],aDArq[LOG_ERROS][2],cStr)	
	Next nI
	lTab	:=	.T.
EndIf

Return Nil

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³   PesqCAI 	³Autor ³ Julio Cesar          ³Data³ 13/05/03 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Pesquisa e retorna o numero do CAI para a factura que esta ³±±   
±±³          ³ sendo processada.                                          ³±±  
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/                                                                
Static Function PesqCAI(cAlias,cInf)
//cAlias=> Alias no qual estao sendo pesquisados os dados (SF1/SF2)
//cInf	=> Informacao que se deseja (1 => Numero do CAI, 2 => Data de Vencimento do CAI)	

Local aAreaAtu   := GetArea()
Local aAreaSFP   := {}
Local cCpoDoc    := SubStr(cAlias,2,2)+"_DOC"
Local cCpoSer    := SubStr(cAlias,2,2)+"_SERIE" 
Local cCpoEsp    := SubStr(cAlias,2,2)+"_ESPECIE"
Local cCpoFil    := SubStr(cAlias,2,2)+"_FILIAL" 
Local cCpoCAI    := SubStr(cAlias,2,2)+"_CAI"
Local cCpoVenCAI := SubStr(cAlias,2,2)+"_VENCAI"
Local cRet       := "" 
Local cEspecie   := ""
                                                   

If (cAlias)->(FieldPos(SubStr(cAlias,2,2)+"_CAE"))>0 .AND. (cAlias)->(FieldPos(SubStr(cAlias,2,2)+"_VCTOCAE")) >0  	
    cCampo:=SubStr(cAlias,2,2)+"_CAE"	                                                   
	If !Empty((cAlias)->&cCampo)
		cCpoCAI    := SubStr(cAlias,2,2)+"_CAE"
		cCpoVenCAI := SubStr(cAlias,2,2)+"_VCTOCAE"
    EndIf
EndIf    
If (cAlias)->(FieldPos(SubStr(cAlias,2,2)+"_CAEE"))>0 .AND. (cAlias)->(FieldPos(SubStr(cAlias,2,2)+"_EMCAEE"))>0   
	cCampo:=SubStr(cAlias,2,2)+"_CAEE"	                                                   
	If !Empty((cAlias)->&cCampo)
		cCpoCAI    := SubStr(cAlias,2,2)+"_CAEE"
		cCpoVenCAI := SubStr(cAlias,2,2)+"_EMCAEE"
	EndIf	
EndIf

//Verifica se trata-se de formulario proprio...
If Empty((cAlias)->&cCpoCAI)
	If AllTrim(SuperGetMV("MV_CONTNF")) == "I"
		//So verifica os tipos abaixo pois somente para os mesmos podera
		//ser realizada a impressao com formulario proprio...
		cEspecie := GetSesNew(AllTrim((cAlias)->&cCpoEsp.),Iif(cAlias$"SD2|SF2","1","2"))
		Do Case
			Case cEspecie == "NF"
				cEspecie := "1"
			Case cEspecie == "NCI"
				cEspecie := "2"		 
			Case cEspecie == "NDI"
				cEspecie := "3"
			Case cEspecie == "NCC"
				cEspecie := "4"
			Case cEspecie == "NDC"
				cEspecie := "5"
		EndCase
	Else
		cEspecie := Space(TAMSX3("FP_ESPECIE")[1])
	EndIf
																
	dbSelectArea("SFP")
	aAreaSFP := GetArea()
	dbSetOrder(6)
	If dbSeek(xFilial("SFP")+(cAlias)->&cCpoFil.+cEspecie+(cAlias)->&cCpoSer.)                       	
    	While !Eof() .And. FP_FILUSO+FP_ESPECIE+FP_SERIE == (cAlias)->&cCpoFil.+cEspecie+(cAlias)->&cCpoSer.
			If (cAlias)->&cCpoDoc. >= FP_NUMINI .And. (cAlias)->&cCpoDoc. <= FP_NUMFIM
				Do Case
					Case cInf == "1"
						cRet := AllTrim(FP_CAI)
					Case cInf == "2"
						cRet := AllTrim(Dtos(FP_DTAVAL))
				EndCase
				Exit
			ElseIf (cAlias)->&cCpoDoc. > FP_NUMFIM
				Exit
			EndIf			
     		dbSkip()
     	End
	EndIf
	RestArea(aAreaSFP)
	RestArea(aAreaAtu)
Else                   
	Do Case
		Case cInf == "1"
			cRet := AllTrim((cAlias)->&cCpoCAI.)
		Case cInf == "2"
			cRet := AllTrim(Dtos((cAlias)->&cCpoVenCAI.))
	EndCase
EndIf               
       
Return(cRet)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³MostraErroºAutor  ³Bruno / Julio       º Data ³  10/06/03   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Mostra erros do processo na tela                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP6                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function MostraErro(cNome)
Local oDlg
Local cMemo
Local cFile    :=""
Local cMask    := STR0056 //"Arquivos Texto (*.TXT) |*.txt|"
Local oFont 

DEFINE FONT oFont NAME "Courier New" SIZE 7,14   //6,15

cMemo :=MemoRead(cNome)
DEFINE MSDIALOG oDlg TITLE cNome From 3,0 to 340,550 PIXEL

@ 5,5 GET oMemo  VAR cMemo MEMO SIZE 267,145 OF oDlg PIXEL 
oMemo:bRClicked := {||AllwaysTrue()}
oMemo:oFont:=oFont

DEFINE SBUTTON  FROM 153,230 TYPE 1 ACTION oDlg:End() ENABLE OF oDlg PIXEL //Apaga
DEFINE SBUTTON  FROM 153,200 TYPE 13 ACTION (cFile:=cGetFile(cMask,OemToAnsi(STR0057)),If(cFile="",.t.,MemoWrite(cFile,cMemo)),oDlg:End()) ENABLE OF oDlg PIXEL //Salva e Apaga //"Salvar Como..." //"Salvar Como..."
//DEFINE SBUTTON  FROM 153,115 TYPE 6 ACTION (PrintAErr(cNome),oDlg:End()) ENABLE OF oDlg PIXEL //Imprime e Apaga

ACTIVATE MSDIALOG oDlg CENTER
                                
Return                                                           

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³FormProp  ºAutor  ³Julio Cesar         º Data ³  10/06/03   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Determina se a factur ou nota foi impressa em formulario    º±± 
±±º          ³proprio.                                                    º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP6                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function FormProp(cEspecie,cTipoMov,cTES,cFormul)

Local lRet := .F.

If Empty(cFormul)
	//Determina a especie da Factura ou Nota...
	cEspecie := GetSesNew(AllTrim(cEspecie),Iif(cTES > "500","1","2"))
	
	If (cEspecie$"NCI|NDI|NCC|NDC|CF") .Or. (cTipoMov == "V" .And. cEspecie == "NF")
		lRet := .T.
	EndIf
Else
	lRet := (AllTrim(cFormul) == "S")
EndIf

Return(lRet)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³PQtdeFol  ºAutor  ³Julio Cesar         º Data ³  10/06/03   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Retorna a quantidade de folhas que a factura/nota possui.   º±± 
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP6                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function PQtdeFol(cAlias)
//cAlias => Alias do arquivo que esta sendo pesquisado no momento.

Local nQtdeFol    := 0
Local cQtdeFol    := ""   
Local cCpoQtdeFol := SubStr(cAlias,2,2)+"_QTDEFOL"                                   
Local nCpoQtdeFol := (cAlias)->(FieldPos(cCpoQtdeFol))

//Verifica se eh formulario proprio...
If !lFormProp
	nQtdeFol := AllTrim((cAlias)->(FieldGet(nCpoQtdeFol)))
EndIf	
     
//Caso o campo ???_QTDEFOL esteja em branco, ou seja formulario proprio
//eh considerado que a quantidade de folhas eh igual a 1...
If Empty(nQtdeFol)
	nQtdeFol := 1
EndIF
cQtdeFol := StrZero(nQtdeFol,3)
	
Return(cQtdeFol)
