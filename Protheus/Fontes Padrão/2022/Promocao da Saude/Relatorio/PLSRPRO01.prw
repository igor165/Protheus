#INCLUDE "PLSRPRO01.ch"
#INCLUDE "PROTHEUS.CH"

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³PLSRPRO    ºAutor  ³ 					 º Data ³  20/12/12   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Imprime listagem dos pacientes odontologico por idade.      º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function PLSRPRO01()
Local wnrel
Local cDesc1 := STR0001 //"Este programa tem como objetivo imprimir o relatório Odontológico por idade"
Local cDesc2 := ""
Local cDesc3 := ""
Local cString := "GCY"

PRIVATE cTitulo:= STR0002 //"Listagem de Pacientes por idade"
PRIVATE cabec1
PRIVATE cabec2
Private aReturn := { "Zebrado", 1,"Administracao", 2, 2, 1, "",1 }
Private cPerg   := "PLRPRO"
Private nomeprog:= "PLSRPRO" 
Private nLastKey:=0
Private Tamanho := "G"
Private nTipo

cabec1:= STR0003 //"Nome                                              Agendamento Atendimento Espera     Nascimento Idade        CRM     Medico                         Especialidade Descrição                                         Local"
cabec2:= "" 
//        1234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890
//                 1         2         3         4         5         6         7         8         9        10        11        12        13        14        15        16        17        18        19        20        21
wnrel := "PLRPRO"

Pergunte(cPerg,.F.)  

wnrel := SetPrint(cString,nomeprog,cPerg,@cTitulo,cDesc1,cDesc2,cDesc3,.F.,,,Tamanho,,.F.)

If nLastKey == 27
   Return
End

SetDefault(aReturn,cString)

If nLastKey == 27
   Return ( NIL )
End

RptStatus({|lEnd| PLSRPROImp(@lEnd,wnRel,cString)},cTitulo)

Return

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³ Fun‡…o    ³PLSRPROImp³ Autor ³  				     ³ Data ³ 20/12/12 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Descri‡…o ³Impressao Odontologica por idade					           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Sintaxe   ³PLSRPROImp(lEnd,wnRel,cString)                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso       ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function PLSRPROImp(lEnd,wnRel,cString)
LOCAL cSQL 
LOCAL nTemEsp := 0
LOCAL nIdade  := 0

li       := 80
m_pag    := 1

cSQL := "SELECT GCY_CODCRM, GCY_CODLOC, GCY_DTNASC, GCY_DATATE, GCY_IDADE, RA_NOME, GBJ_ESPEC1, GFR_DSESPE, GM8_DATCAD, GM8_NOMPAC  "
cSQL += "  FROM " + RetSQLName("GCY")+" GCY "
cSQL += " INNER JOIN " + RetSQLName("GM8")+" GM8 "
cSQL += "    ON GM8_FILAGE = GCY_FILIAL  "
cSQL += "   AND GM8_REGATE = GCY_REGATE  "
cSQL += "   AND GM8.D_E_L_E_T_ = ' '

cSQL += " INNER JOIN " + RetSQLName("GBJ")+" GBJ "
cSQL += "   ON GBJ_FILIAL = GCY_FILIAL  "
cSQL += "  AND GBJ_CRM    = GCY_CODCRM  "

If !Empty(MV_PAR01)
	cSQL += "  AND GBJ_ESPEC1 = '"+MV_PAR01+"' "
	cSQL += "  AND GBJ.D_E_L_E_T_ = ' ' "
EndIf

cSQL += " INNER JOIN " + RetSQLName("SRA")+" SRA "
cSQL += "   ON RA_CODIGO = GBJ_CRM  "
cSQL += "  AND SRA.D_E_L_E_T_ = ' ' " 

cSQL += " INNER JOIN " + RetSQLName("GFR")+" GFR "
cSQL += "   ON GFR_FILIAL = ' ' "
cSQL += "  AND GFR_CDESPE =  GBJ_ESPEC1 "
cSQL += "  AND GFR.D_E_L_E_T_ = ' '  "
cSQL += " WHERE GCY.D_E_L_E_T_ = ' '  "

If !Empty(MV_PAR04) .Or. !Empty(MV_PAR05)
	cSQL += " AND GCY_DATATE BETWEEN '"+DTOS(MV_PAR04)+"' AND '"+DTOS(MV_PAR05)+"' " //Data de Atendimento
EndIf

cSQL += " ORDER BY GCY_CODLOC, GCY_CODCRM, GM8_DATCAD, GCY_DATATE"

PLSQuery(cSQL,"QRYPRO")

dbSelectArea("QRYPRO")
QRYPRO->(DbGoTop())

SetRegua(RecCount())

While QRYPRO->(! Eof())

	IncRegua()  
	
	If li > 55
		cabec(cTitulo,cabec1,cabec2,nomeprog,tamanho,nTipo)
	EndIf
	
	nTemEsp := VAL(DTOC(QRYPRO->GCY_DATATE)) - VAL(DTOC(QRYPRO->GM8_DATCAD)) 
	nIdade  := Val(SUBSTR(DTOC(dDataBase),7,4)) - Val(SUBSTR(DTOC(QRYPRO->GCY_DTNASC),7,4))
	
//		  "Nome                                              Agendamento Atendimento Espera     Nascimento Idade        CRM     Medico                         Especialidade Descrição                                         Local"
//        1234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890
//                 1         2         3         4         5         6         7         8         9        10        11        12        13        14        15        16        17        18        19        20        21
	If !Empty(MV_PAR02) .And. !Empty(MV_PAR03) 
		If nIdade >= MV_PAR02 .And. nIdade <= MV_PAR03
			@ li, 000 PSay QRYPRO->GM8_NOMPAC //NOME
			@ li, 050 PSay QRYPRO->GM8_DATCAD //AGENDAMENTO
			@ li, 062 PSay QRYPRO->GCY_DATATE //ATENDIMENTO
			@ li, 074 PSay nTemEsp            //ESPERA
			@ li, 085 PSay QRYPRO->GCY_DTNASC //NASCIMENTO
			@ li, 096 PSay nIdade			  //IDADE
			@ li, 109 Psay QRYPRO->GCY_CODCRM //CRM
			@ li, 117 Psay QRYPRO->RA_NOME    //MEDICO
			@ li, 148 Psay QRYPRO->GBJ_ESPEC1 //ESPECIALIDADE
			@ li, 162 Psay QRYPRO->GFR_DSESPE //DESCRIÇÃO
			@ li, 212 Psay QRYPRO->GCY_CODLOC //LOCAL 
			li++
		EndIf 
	
	ElseIf !Empty(MV_PAR02) .And. nIdade >= MV_PAR02    
		@ li, 000 PSay QRYPRO->GM8_NOMPAC //NOME
		@ li, 050 PSay QRYPRO->GM8_DATCAD //AGENDAMENTO
		@ li, 062 PSay QRYPRO->GCY_DATATE //ATENDIMENTO
		@ li, 074 PSay nTemEsp            //ESPERA
		@ li, 085 PSay QRYPRO->GCY_DTNASC //NASCIMENTO
		@ li, 096 PSay nIdade			  //IDADE
		@ li, 109 Psay QRYPRO->GCY_CODCRM //CRM
		@ li, 117 Psay QRYPRO->RA_NOME    //MEDICO
		@ li, 148 Psay QRYPRO->GBJ_ESPEC1 //ESPECIALIDADE
		@ li, 162 Psay QRYPRO->GFR_DSESPE //DESCRIÇÃO
		@ li, 212 Psay QRYPRO->GCY_CODLOC //LOCAL 
		li++
	EndIf	

	QRYPRO->(DbSkip())

EndDo

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Recupera a Integridade dos dados                             ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
dbSelectArea("QRYPRO")
dbCloseArea()

dbSelectArea("GCY")

Set Device To Screen

If aReturn[5] = 1
   Set Printer To
	dbCommitAll()
   OurSpool(wnrel)
Endif

MS_FLUSH()

Return