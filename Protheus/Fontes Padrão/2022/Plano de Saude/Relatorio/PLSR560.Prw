
#INCLUDE "PLSR560.ch"
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออหอออออออัอออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณPLSR560    บAutor  ณPaulo Carnelossi   บ Data ณ  17/09/03   บฑฑ
ฑฑฬออออออออออุอออออออออออสอออออออฯอออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณImprime relatorio de negociacoes calculo um determinado     บฑฑ
ฑฑบ          ณcontrato/produto/Mes/Ano                                    บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function PLSR560()
//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Define Variaveis                                             ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
Local wnrel
Local cDesc1 := STR0001 //"Este programa tem como objetivo imprimir as negociacoes ocorridas "
Local cDesc2 := STR0002 //"um determinado contrato/produto/Mes/Ano."
Local cDesc3 := ""
Local cString := "BHW"
Local Tamanho := "G"

PRIVATE cTitulo := STR0003 //"Relatorio Negociacoes de Produto"
PRIVATE cabec1  := ""
PRIVATE cabec2  := ""
PRIVATE aOrder  := ""
Private aReturn := { STR0004, 1,STR0005, 2, 2, 1, "",1 } //"Zebrado"###"Administracao"
Private cPerg   := "PLR560"
Private nomeprog:= "PLSR560" 
Private nLastKey:=0
Private cCodInt := ""
M->BJM_CODINT :=  "  "
M->BD5_CODINT := "  "

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Definicao dos cabecalhos                                     ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู

//        123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890
//                 1         2         3         4         5         6         7         8         9        10        11        12        13        14        15
//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Envia controle para a funcao SETPRINT                        ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
wnrel := "PLR560"

Pergunte(cPerg,.F.)

M->BJM_CODINT :=  M->BD5_CODINT := mv_par01  // para filtrar produto correto XB

wnrel := SetPrint(cString,wnrel,cPerg,@cTitulo,cDesc1,cDesc2,cDesc3,.F.,aOrder,,Tamanho,,.F.)

If nLastKey == 27
   Return
End

SetDefault(aReturn,cString)

If nLastKey == 27
   Return ( NIL )
End

RptStatus({|lEnd| PLSR560Imp(@lEnd,wnRel,cString)},cTitulo)

Return
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑฺฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฟฑฑ
ฑฑณ Fun…o    ณPLSR560Impณ Autor ณ Paulo Carnelossi      ณ Data ณ 09/09/03 ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณ Descri…o ณImpressao rel.negociacao de contrato/produto/Mes/Ano        ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณ Sintaxe   ณPLSR560Imp(lEnd,wnRel,cString)                              ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณ Uso       ณ                                                            ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/
Static Function PLSR560Imp(lEnd,wnRel,cString)
Local cbcont,cbtxt
Local tamanho:= "G"
Local nTipo
LOCAL aTitFai := {}
LOCAL cSql
//Local cArqTrab := CriaTrab(nil,.F.)
LOCAL cTitFai := ''
LOCAL nPos := 0
LOCAL nTotal := 0
//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Variaveis utilizadas para Impressao do Cabecalho e Rodape    ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
cbtxt    := SPACE(10)
cbcont   := 0
li       := 80
m_pag    := 1   

cTitulo +=  STR0006+mv_par02+STR0007+mv_par01+" - "+ Padr(Posicione("BA0",1,xFilial("BA0")+mv_par01,"BA0_NOMINT"),45) //" Mes : "###"   ***  Operadora : "
cabec1 := STR0008 //"EMPRESA  CONTRATO/VERSAO    SUB-CONTRATO/VERSAO NOME DA EMPRESA                 RENTAB PRODUTO VERSAO  USUARIOS   MENSALIDADE    INDICE    MENSALIDADE"
cabec2 := "                                                                                                                     ATUAL                 C/ REAJUSTE                        "


nTipo:=GetMv("MV_COMP")
/*
PLR560  ฆ01      ฆOperadora
PLR560  ฆ02      ฆMes/Ano
PLR560  ฆ03      ฆEmpresa de
PLR560  ฆ04      ฆEmpresa ate
PLR560  ฆ05      ฆContrato de 
PLR560  ฆ06      ฆVersao Contrato de 
PLR560  ฆ07      ฆContrato ate
PLR560  ฆ08      ฆVersao Contrato Ate
PLR560  ฆ09      ฆSub-Contrato de
PLR560  ฆ10      ฆVersao Sub-Contrato de
PLR560  ฆ11      ฆSub-Contrato ate
PLR560  ฆ12      ฆVersao Sub-Contrato ate
PLR560  ฆ13      ฆReaj./Sim./Ambos
PLR560  ฆ13      ฆMeses Historico
*/       
cSql := "Select * From "+RetSqlName("BJ1")+" Where BJ1_FILIAL = '"+xFilial("BJ1")+"' AND D_E_L_E_T_ <> '*' "
PlsQuery(cSql,"TrbBJ1")    

TrbBJ1->( dbEval({|| Aadd(aTitFai,{TrbBJ1->BJ1_CODIGO,TrbBJ1->BJ1_DESCRI}) }) )
TrbBJ1->( dbClosearea() )

dbSelectArea("BHW")

cSql := "SELECT BHW_CODINT, BHW.BHW_CODEMP, BHW.BHW_CONEMP, BHW.BHW_VERCON, BHW.BHW_SUBCON, BHW_STATUS,"
cSql += "BHW.BHW_VERSUB, BHW.BHW_RENTBL, BHW.BHW_CODPLA, BHW.BHW_VERSAO, BHW_MATRIC, BHW_TIPREG, BHW_DIGITO, "
cSql += " BHW.BHW_NROUSU, BHW.BHW_VALOR, BHW.BHW_PERPAD, "
cSql += " BHW.BHW_MSG01, BHW.BHW_MSG02, BHW.BHW_MSG03,BHW_ANOMES FROM "
cSql += RetSQLName("BHW")+" BHW "

cSql += "WHERE "

//--considerar somente registros validos
cSql += "BHW.D_E_L_E_T_ <> '*' AND BHW.BHW_MATRIC = ' ' AND "

//--condicao principal                     

cSql += "	BHW.BHW_FILIAL = '"+xFilial("BHW")+"' AND "
cSql += "	BHW.BHW_CODINT = '"+MV_PAR01+"' AND "
cSql += "	BHW.BHW_ANOMES = '"+Right(MV_PAR02,4)+Left(MV_PAR02,2)+"' AND "

//--Empresa
cSql += "	BHW.BHW_CODEMP >= '"+MV_PAR03+"' AND "
cSql += "	BHW.BHW_CODEMP <= '"+MV_PAR04+"' AND "

//--CONTRATO
cSql += "	BHW.BHW_CONEMP >='"+MV_PAR05+"' AND BHW_VERCON >= '"+MV_PAR06+"' AND "
cSql += "	BHW.BHW_CONEMP <='"+MV_PAR07+"' AND BHW_VERCON <= '"+MV_PAR08+"' AND "

//--SUB CONTRATO
cSql += "	BHW.BHW_SUBCON >='"+MV_PAR09+"' AND BHW_VERSUB >= '"+MV_PAR10+"' AND "
cSql += "	BHW.BHW_SUBCON <='"+MV_PAR11+"' AND BHW_VERSUB <= '"+MV_PAR12+"'  "

If mv_par13 == 1   // Reajuste
	cSql += "	AND "
	//--Contrato e Sub Contrato
	cSql += "	BHW.BHW_STATUS ='1' "
ElseIf mv_par13 == 2   // Simulacao
	cSql += "	AND "
	//--Contrato e Sub Contrato
	cSql += "	BHW.BHW_STATUS ='0' "
EndIf

cSql += " ORDER BY BHW_STATUS+BHW_CODEMP+BHW_CONEMP+BHW_SUBCON+BHW_ANOMES+BHW_CODPLA+BHW_VERSAO"

PLSQuery(cSql,"cArqTrab")

dbSelectArea("cArqTrab")
SetRegua(RecCount())
cArqTrab->(dbGotop())

While cArqTrab->(! EOF())
	
	IncRegua()
	
	If li > 58
		cabec(cTitulo,cabec1,cabec2,nomeprog,tamanho,nTipo)
	EndIf
	
	cChave := cArqTrab->(BHW_CODINT+BHW_CONEMP+BHW_VERCON+BHW_SUBCON+BHW_VERSUB+BHW_CODPLA+BHW_VERSAO+BHW_ANOMES)
	
	While !cArqTrab->( Eof() ) .and. cArqTrab->(BHW_CODINT+BHW_CONEMP+BHW_VERCON+;
							  		BHW_SUBCON+BHW_VERSUB+BHW_CODPLA+BHW_VERSAO+BHW_ANOMES) == cChave
		
		@ li, 000 PSAY cArqTrab->BHW_CODEMP + Space(5)+;
		cArqTrab->BHW_CONEMP+"/"+cArqTrab->BHW_VERCON+Space(3)+;
		cArqTrab->BHW_SUBCON+"/"+cArqTrab->BHW_VERSUB+Space(7)+;
		Padr(Posicione("BG9", 1, xFilial("BG9")+mv_par01+cArqTrab->BHW_CODEMP,"BG9_DESCRI"),30)+Space(1)+;
		Transform(cArqTrab->BHW_RENTBL, "@E ,999.99")+Space(3)+;
		cArqTrab->BHW_CODPLA+Space(3)+;
		cArqTrab->BHW_VERSAO+Space(3)+;
		Transform(cArqTrab->BHW_NROUSU, "99999999")+Space(1)+;
		Transform(cArqTrab->BHW_VALOR, "@E 99,999,999.99")+Space(2)+;
		Transform(cArqTrab->BHW_PERPAD, "@E ,999.99")+" %"+Space(1)+;
		Transform(cArqTrab->BHW_VALOR*(100+cArqTrab->BHW_PERPAD)/100, "@E 99,999,999.99")
		

		li+=2
		@ li, 030 PSAY "OBS: " + cArqTrab->BHW_MSG01
		li++
		@ li, 030 PSAY "OBS: " + cArqTrab->BHW_MSG02
		li++
		@ li, 030 PSAY "OBS: " + cArqTrab->BHW_MSG03
		li++
		@ li, 020 PSAY PadC("Historico das Negociacoes",180,"-")
		li++
//		Impr_Historico(mv_par02, mv_par14, "cArqTrab")
		@ li, 000 PSAY Repl("=",220)
		li++
		
		cArqTrab->(dbSkip())
	Enddo
Enddo

IF li != 80
	roda(cbcont,cbtxt,tamanho)
End

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Recupera a Integridade dos dados                             ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
dbSelectArea("cArqTrab")
dbCloseArea()

dbSelectArea("BHW")

Set Device To Screen

If aReturn[5] = 1
   Set Printer To
	dbCommitAll()
   OurSpool(wnrel)
Endif

MS_FLUSH()

Return


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออออออหออออออัออออออออออออออออออหออออออัออออออออออออปฑฑ
ฑฑบPrograma  ณImpr_HistoricoบAutor ณPaulo Carnelossi  บ Data ณ 16/09/03   บฑฑ
ฑฑฬออออออออออุออออออออออออออสออออออฯออออออออออออออออออสออออออฯออออออออออออนฑฑ
ฑฑบDesc.     ณImprime Historico das negociacoes de acordo com mes         บฑฑ
ฑฑบ          ณinformado e qtde de meses                                   บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿

Static Function Impr_Historico(cMesAno, nQtdMeses, cArqTrab)
Local cMesInf := cMesAno, cSql := "", cTrbArq := CriaTrab(NIL, .F.)

cMesAno := RetrocedeMesAno(cMesAno, nQtdMeses)

cSql := "SELECT BHW.BHW_ANOMES, BHW.BHW_MSG01, BHW.BHW_MSG02, BHW.BHW_MSG03,  "
cSql += " BHW.BHW_RENTBL,  BHW.BHW_VALOR, BHW.BHW_PERPAD FROM  "
cSql += RetSQLName("BHW")+" BHW "

cSql += "WHERE "

//--considerar somente registros validos
cSql += "BHW.D_E_L_E_T_ <> '*' AND BHW.BHW_MATRIC = ' ' AND "

//--condicao principal                     

cSql += "	BHW.BHW_FILIAL = '"+xFilial("BHW")+"' AND "
cSql += "	BHW.BHW_CODINT = '"+MV_PAR01+"' AND "
cSql += "	BHW.BHW_ANOMES >= '"+Right(cMesAno,4)+Left(cMesAno,2)+"' AND "
cSql += "	BHW.BHW_ANOMES < '"+Right(cMesInf,4)+Left(cMesInf,2)+"' AND "

//--Empresa
cSql += "	BHW.BHW_CODEMP = '"+(cArqTrab)->BHW_CODEMP+"' AND "
//--CONTRATO
cSql += "	BHW.BHW_CONEMP ='"+(cArqTrab)->BHW_CONEMP+"' AND BHW_VERCON = '"+(cArqTrab)->BHW_VERCON+"' AND "

//--SUB CONTRATO
cSql += "	BHW.BHW_SUBCON ='"+(cArqTrab)->BHW_SUBCON+"' AND BHW_VERSUB = '"+(cArqTrab)->BHW_VERSUB+"' "

If mv_par13 == 1   // Reajuste
	cSql += "	AND "
	//--Contrato e Sub Contrato
	cSql += "	BHW.BHW_STATUS ='1' "
ElseIf mv_par13 == 2   // Simulacao
	cSql += "	AND "
	//--Contrato e Sub Contrato
	cSql += "	BHW.BHW_STATUS ='0' "
EndIf

cSql += " ORDER BY BHW_ANOMES DESC"
PlsQuery(cSql, cTrbArq)
   
dbSelectArea(cTrbArq)
(cTrbArq)->(dbGotop())

While	(cTrbArq)->(! EOF())
   	@ Li, 030 PSAY Right((cTrbArq)->BHW_ANOMES,2)+"/"+Left((cTrbArq)->BHW_ANOMES,4)+STR0009+(cTrbArq)->BHW_MSG01+STR0010+Transform((cArqTrab)->BHW_RENTBL, "@E ,999.99")+STR0011+Transform((cArqTrab)->BHW_PERPAD, "@E ,999.99")+" %" //" - Obs: "###"       Rentabilidade: "###"   Percentual: "
   	li++
   	If ! Empty((cTrbArq)->BHW_MSG02)
	   	@ Li, 045 PSAY (cTrbArq)->BHW_MSG02
	   	li++
	Endif
   	If ! Empty((cTrbArq)->BHW_MSG03)
	   	@ Li, 045 PSAY (cTrbArq)->BHW_MSG03
   		li++
   	Endif
	(cTrbArq)->(dbSkip())
End	

dbSelectArea(cTrbArq)
dbCloseArea()
   
Return NIL
*/
