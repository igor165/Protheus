#INCLUDE "Finr991.ch"
#INCLUDE "rwmake.ch"

/*/
苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北�
北谀哪哪哪哪穆哪哪哪哪哪履哪哪哪履哪哪哪哪哪哪哪哪哪哪哪履哪哪穆哪哪哪哪哪勘�
北矲un噮o    � FINR991  � Autor � Daniel Tadashi Batori � Data � 31.07.06 潮�
北媚哪哪哪哪呐哪哪哪哪哪聊哪哪哪聊哪哪哪哪哪哪哪哪哪哪哪聊哪哪牧哪哪哪哪哪幢�
北矰escri噮o � Funcao para geracao de livro de honorarios                 潮�
北媚哪哪哪哪呐哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪幢�
北砈intaxe e � FINR991(void)                                              潮�
北媚哪哪哪哪呐哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪幢�
北砅arametros�                                                            潮�
北媚哪哪哪哪呐哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪幢�
北� Uso      � Generico                                                   潮�
北滥哪哪哪哪牧哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪俦�
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北�
哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌
*/
Function FINR991()

Local oReport

If TRepInUse()
	oReport := ReportDef()
	oReport:PrintDialog()
Else
	Return FINR991R3() // Executa vers鉶 anterior do fonte
Endif

Return

/*
苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘�
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北�
北谀哪哪哪哪穆哪哪哪哪哪履哪哪哪履哪哪哪哪哪哪哪哪哪哪哪履哪哪穆哪哪哪哪哪勘�
北矲un噮o    � ReportDef� Autor � Daniel Batori         � Data � 31.07.06 潮�
北媚哪哪哪哪呐哪哪哪哪哪聊哪哪哪聊哪哪哪哪哪哪哪哪哪哪哪聊哪哪牧哪哪哪哪哪幢�
北矰escri噮o � Definicao do layout do Relatorio									  潮�
北媚哪哪哪哪呐哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪幢�
北砈intaxe   � ReportDef(void)                                            潮�
北媚哪哪哪哪呐哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪幢�
北� Uso      � Generico                                                   潮�
北滥哪哪哪哪牧哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪俦�
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北�
哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌�
*/
Static Function ReportDef()
Local oReport  
Local oSection1

oReport := TReport():New("FINR991",STR0005,"FIR991",;
{|oReport| ReportPrint(oReport)},STR0001+STR0002)

oReport:SetPortrait(.T.)

pergunte("FIR991",.F.)
//谀哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪�
//� Variaveis utilizadas para parametros                        �
//� mv_par01            // Data De                              �
//� mv_par02            // Data Ate                             �
//滥哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪�

nTam	:= TamSX3("E2_VALOR")[1]
cPict := PesqPict("SE2","E2_VALOR")

oSection1 := TRSection():New(oReport,,{"SE2"},)
TRCell():New(oSection1,"E2_CGC",		"SE2",,,,.F.,)
TRCell():New(oSection1,"E2_NOMFOR",	"SE2",STR0006,,,.F.,)  			// "Nombre"
TRCell():New(oSection1,"E2_NUM",		"SE2",STR0007,,,.F.,)				// "Nr. Billete"
TRCell():New(oSection1,"VALOR1",		"SE2",STR0008,cPict,nTam,.F.,)  // "Honorario"
TRCell():New(oSection1,"VALOR2",		"SE2",STR0009,cPict,nTam,.F.,)  // "Valor Retenido"
TRCell():New(oSection1,"VALOR3",		"SE2",STR0010,cPict,nTam,.F.,)  // "Valor Neto"

oSection1:SetHeaderSection(.T.)

Return oReport                                                                              

/*
苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘�
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北�
北谀哪哪哪哪穆哪哪哪哪哪穆哪哪哪穆哪哪哪哪哪哪哪哪哪哪哪穆哪哪哪履哪哪哪哪目北
北砅rograma  砇eportPrint� Autor 矰aniel Batori          � Data �31.07.06	潮�
北媚哪哪哪哪呐哪哪哪哪哪牧哪哪哪牧哪哪哪哪哪哪哪哪哪哪哪牧哪哪哪聊哪哪哪哪拇北
北矰escri噮o 矨 funcao estatica ReportDef devera ser criada para todos os  潮�
北�          硆elatorios que poderao ser agendados pelo usuario.           潮�
北媚哪哪哪哪呐哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪拇北
北砇etorno   砃enhum                                                       潮�
北媚哪哪哪哪呐哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪拇北
北砅arametros矱xpO1: Objeto Report do Relat髍io                            潮�
北媚哪哪哪哪呐哪哪哪哪哪哪哪穆哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪拇北
北�   DATA   � Programador   矼anutencao efetuada                          潮�
北媚哪哪哪哪呐哪哪哪哪哪哪哪呐哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪拇北
北�          �               �                                             潮�
北滥哪哪哪哪牧哪哪哪哪哪哪哪牧哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪馁北
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北�
哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌�
*/
Static Function ReportPrint(oReport)
Local oSection1  := oReport:Section(1)
Local cAliasQry1 := GetNextAlias()
Local cChave := ""
Local cQuery := ""

dbSelectArea("SE2")
cChave := SE2->(IndexKey(1))

#IFDEF TOP

	oSection1:BeginQuery()
		cQuery += " ORDER BY " + SqlOrder(cChave)
		cQuery := "%" + cQuery + "%"
		
		BeginSql Alias cAliasQry1
			SELECT  *
			FROM %table:SE2% SE2
			WHERE	E2_FILIAL = %xFilial:SE5% AND
			RTRIM(E2_TIPO) = 'BOL' AND
			E2_EMIS1 BETWEEN %exp:MV_PAR01% AND %exp:MV_PAR02% AND
			SE2.%NotDel%
			%Exp:cQuery%
		EndSQL
	oSection1:EndQuery()

#ELSE	

	cAliasQry1 := "SE2"
	
	cQuery += " E2_FILIAL  == '" + xFilial("SE2") + "' .And. "
	cQuery += " E2_TIPO == 'BOL' .And. "
	cQuery += " DTOS(E2_EMIS1) >= '" + DTOS(mv_par01) + "' .And. "
	cQuery += " DTOS(E2_EMIS1) <= '" + DTOS(mv_par02) + "' "

	oSection1:SetFilter(cQuery,cChave)

#ENDIF

oReport:SetTitle( STR0005 + MesExtenso(mv_par01) + "/" + SubStr(Dtos(mv_par01),1,4))

oSection1:Cell("VALOR1"):SetHeaderAlign("RIGHT")
oSection1:Cell("VALOR2"):SetHeaderAlign("RIGHT")
oSection1:Cell("VALOR3"):SetHeaderAlign("RIGHT")

oSection1:Cell("E2_CGC"):SetBlock(		{ || (cAliasQry1)->E2_CGC })
oSection1:Cell("E2_NOMFOR"):SetBlock(	{ || (cAliasQry1)->E2_NOMFOR })
oSection1:Cell("E2_NUM"):SetBlock(		{ || (cAliasQry1)->E2_NUM })
oSection1:Cell("VALOR1"):SetBlock(		{ || (cAliasQry1)->E2_VALOR / 0.9 })
oSection1:Cell("VALOR2"):SetBlock(		{ || ((cAliasQry1)->E2_VALOR/0.9) - (cAliasQry1)->E2_VALOR })
oSection1:Cell("VALOR3"):SetBlock(		{ || (cAliasQry1)->E2_VALOR })

TRFunction():New(oSection1:Cell("VALOR1")	,"T_VALOR2","SUM",,,,,.T.,.F.)
TRFunction():New(oSection1:Cell("VALOR2")	,"T_VALOR2","SUM",,,,,.T.,.F.)
TRFunction():New(oSection1:Cell("VALOR3")	,"T_VALOR2","SUM",,,,,.T.,.F.)

oSection1:SetTotalInLine(.F.)

oSection1:SetTotalText(STR0013) //"Totales"

oSection1:Print()

Return
      










/*
---------------------------------------------------------- RELEASE 3 ---------------------------------------------
*/













/*/
苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘�
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北�
北赏屯屯屯屯脱屯屯屯屯屯送屯屯屯淹屯屯屯屯屯屯屯屯屯退屯屯屯淹屯屯屯屯屯屯槐�
北篜rograma  � Finr991R3� Autor � Paulo Eduardo      � Data �  29/07/03   罕�
北掏屯屯屯屯拓屯屯屯屯屯释屯屯屯贤屯屯屯屯屯屯屯屯屯褪屯屯屯贤屯屯屯屯屯屯贡�
北篋escricao � Funcao para geracao de livro de honorarios                 罕�
北�          �                                                            罕�
北掏屯屯屯屯拓屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯贡�
北篣so       � AP6                                                        罕�
北韧屯屯屯屯拖屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯急�
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北�
哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌�
/*/

Function Finr991R3()
//谀哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪�
//� Declaracao de Variaveis                                             �
//滥哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪�

Local cDesc1         := STR0001 //"Este programa imprime livro de honorarios "
Local cDesc2         := STR0002 //"de acordo com os parametros informados pelo usuario."
Local cDesc3         := "FINR991"
Local cPict          := ""
Local titulo       := ""
Local nLin         := 80
Local Cabec1       := ""
Local Cabec2       := ""
Local imprime      := .T.
Local aOrd := {}         
Local cQuery := "",cCond := ""
Private lEnd         := .F.
Private lAbortPrint  := .F.
Private limite           := 132
Private tamanho          := "M"
Private nomeprog         := "FINR991" // Coloque aqui o nome do programa para impressao no cabecalho
Private nTipo            := 18
Private aReturn          := { STR0003, 1, STR0004, 2, 2, 1, "", 1} //"Zebrado"###"Administracao"
Private nLastKey        := 0
Private cbtxt      := Space(10)
Private cbcont     := 00
Private CONTFL     := 01
Private m_pag      := 01
Private wnrel      := "LIBHNR" // Coloque aqui o nome do arquivo usado para impressao em disco
Private cPerg	   := "FIR991"

Private cAliasSE2  := "SE2"   
Private nOrdSE2	   := 0
Private cArqTrab   := ""

//谀哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪目
//矱xibe parametros para a impressao     �
//滥哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪馁

Pergunte(cPerg,.F.)
                   
//谀哪哪哪哪哪哪哪哪哪哪哪哪哪哪目
//矼onta o cabecalho do relatorio�
//滥哪哪哪哪哪哪哪哪哪哪哪哪哪哪馁
titulo := STR0005+MesExtenso(mv_par01)+"/"+SubStr(Dtos(mv_par01),1,4) //"Livro de Honorarios - "

Cabec1 := PadR(AllTrim(RetTitle("E2_CGC")),14)+Space(2)+PadR(STR0006,40)+Space(2)+PadR(STR0007,15) +; //"Nome"###"Nr. Bilhete"
		Space(2)+PadL(STR0008,17)+Space(2)+PadL(STR0009,17)+Space(2)+PadL(STR0010,17) //"Honorario"###"Montante Retido"###"Montante Liquido"
		
//谀哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪�
//� Monta a interface padrao com o usuario                              �
//滥哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪�

wnrel := SetPrint(cAliasSE2,NomeProg,cPerg,@titulo,cDesc1,cDesc2,cDesc3,.T.,aOrd,.T.,Tamanho,,.T.)

If nLastKey == 27
	Return
Endif

SetDefault(aReturn,cAliasSE2)

If nLastKey == 27
   Return
Endif

nTipo := If(aReturn[4]==1,15,18)

//谀哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪�
//� Processamento. RPTSTATUS monta janela com a regua de processamento. �
//滥哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪�

RptStatus({|| Imprime(Cabec1,Cabec2,Titulo,nLin) },Titulo)
Return

/*/
苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘�
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北�
北赏屯屯屯屯脱屯屯屯屯屯送屯屯屯淹屯屯屯屯屯屯屯屯屯退屯屯屯淹屯屯屯屯屯屯槐�
北篎un噭o    砇UNREPORT � Autor � AP6 IDE            � Data �  29/07/03   罕�
北掏屯屯屯屯拓屯屯屯屯屯释屯屯屯贤屯屯屯屯屯屯屯屯屯褪屯屯屯贤屯屯屯屯屯屯贡�
北篋escri噭o � Funcao auxiliar chamada pela RPTSTATUS. A funcao RPTSTATUS 罕�
北�          � monta a janela com a regua de processamento.               罕�
北掏屯屯屯屯拓屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯贡�
北篣so       � Programa principal                                         罕�
北韧屯屯屯屯拖屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯急�
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北�
哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌�
/*/

Static Function Imprime(Cabec1,Cabec2,Titulo,nLin)

Local cbtxt      := Space(10)
Local cbcont     := 00
Local nTotHon :=0, nTotRet :=0, nTotLiq :=0
//谀哪哪哪哪哪哪哪哪哪哪哪哪哪哪��
//矲iltra os dados para impressao�
//滥哪哪哪哪哪哪哪哪哪哪哪哪哪哪��

#IFDEF TOP
	cAliasSE2:="E2TMP"
	If Select(cAliasSE2)<>0
   		DbSelectArea(cAliasSE2)
   		DbCloseArea()
	Endif            

	cQuery := "SELECT * FROM "+RetSqlName("SE2")+" "+cAliasSE2+" "
    cQuery += "WHERE E2_FILIAL='"+ xFilial("SE2")+"'"+" AND RTRIM(E2_TIPO) = 'BOL' "
    cQuery += "AND E2_EMIS1 >='"+ Dtos(mv_par01) +"' AND E2_EMIS1 <='"+ Dtos(mv_par02) +"'" 
    cQuery +=" AND D_E_L_E_T_<>'*' ORDER BY " 
    cQuery +="E2_PREFIXO,E2_NUM,E2_PARCELA,E2_TIPO,E2_FORNECE,E2_LOJA"
    cQuery :=ChangeQuery(cQuery)
	MsAguarde({|| dbUseArea(.T.,"TOPCONN",TCGenQry(,,cQuery),cAliasSE2,.F.,.T.)},STR0011) //"Selecionando Registros ..."
	TCSetField(cAliasSE2,"E2_EMIS1","D",8,0)
#ELSE
	cAliasSE2:="SE2"
	DbSelectArea(cAliasSE2)
	DbGoTop()         

	nOrdSE2 := IndexOrd()
            
	cCond := cAliasSE2+"->E2_FILIAL == '"+ xFilial(cAliasSE2) + "'.and. AllTrim("+ cAliasSE2 +"->E2_TIPO) == 'BOL'"
	cCond += ".and. "+"AllTrim(Dtos("+ cAliasSE2 +"->E2_EMIS1)) >='"+ Dtos(mv_par01)+"' .and."
	cCond += "AllTrim(Dtos("+ cAliasSE2 +"->E2_EMIS1)) <= '"+ Dtos(mv_par02) +"'"
	cArqTrab := CriaTrab(Nil,.F.)
	IndRegua(cAliasSE2,cArqTrab,IndexKey(),,cCond,STR0011)  //"Selecionando Registros ..."
#ENDIF	   

dbSelectArea(cAliasSE2)

//谀哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪�
//� SETREGUA -> Indica quantos registros serao processados para a regua �
//滥哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪�

SetRegua(RecCount())

dbGoTop()
While !(cAliasSE2)->(EOF())

   //谀哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪�
   //� Verifica o cancelamento pelo usuario...                             �
   //滥哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪�

   If lAbortPrint
      @nLin,00 PSAY STR0012 //"*** CANCELADO PELO OPERADOR ***"
      Exit
   Endif

   //谀哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪�
   //� Impressao do cabecalho do relatorio                                 �
   //滥哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪�

   If nLin > 55 
      nLin := Cabec(Titulo,Cabec1,Cabec2,NomeProg,Tamanho,nTipo)
      nLin++
   Endif

   @nLin,00  PSAY Transform((cAliasSE2)->E2_CGC,PesqPict(cAliasSE2,"E2_CGC"))
   @nLin,16  PSAY (cAliasSE2)->E2_NOMFOR
   @nLin,58  PSAY (cAliasSE2)->E2_NUM
   @nLin,74  PSAY Transform((cAliasSE2)->E2_VALOR/0.9,PesqPict(cAliasSE2,"E2_VALOR"))
   @nLin,93  PSAY Transform(((cAliasSE2)->E2_VALOR/0.9)-(cAliasSE2)->E2_VALOR,PesqPict(cAliasSE2,"E2_VALOR"))
   @nLin,112 PSAY Transform((cAliasSE2)->E2_VALOR,PesqPict(cAliasSE2,"E2_VALOR"))

   nLin := nLin + 1 // Avanca a linha de impressao
   
   nTotHon += (cAliasSE2)->E2_VALOR/0.9
   nTotRet += ((cAliasSE2)->E2_VALOR/0.9)-(cAliasSE2)->E2_VALOR
   nTotLiq += (cAliasSE2)->E2_VALOR

   dbSkip() 
EndDo                         

nLin := nLin + 1                                
                                               
@nLin,58  PSAY STR0013                          //"Totais"
@nLin,74  PSAY Transform(nTotHon,PesqPict(cAliasSE2,"E2_VALOR"))
@nLin,93  PSAY Transform(nTotRet,PesqPict(cAliasSE2,"E2_VALOR"))
@nLin,112 PSAY Transform(nTotLiq,PesqPict(cAliasSE2,"E2_VALOR"))

roda(cbcont,cbtxt,"M")

#IFDEF TOP
	DbSelectArea(cAliasSE2)
	DbCloseArea()
#ELSE
	RetIndex(cAliasSE2)
	(cAliasSE2)->(DbSetOrder(nOrdSE2))
	cArqTrab+=OrdBagExt()
	File(cArqTrab)
	Ferase(cArqTrab)
#ENDIF	

//谀哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪�
//� Finaliza a execucao do relatorio                                    �
//滥哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪�

SET DEVICE TO SCREEN

//谀哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪�
//� Se impressao em disco, chama o gerenciador de impressao             �
//滥哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪�

If aReturn[5]==1
   dbCommitAll()
   SET PRINTER TO
   OurSpool(wnrel)
Endif

MS_FLUSH()

Return