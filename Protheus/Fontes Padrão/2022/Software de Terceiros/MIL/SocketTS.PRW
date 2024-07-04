#INCLUDE "PROTHEUS.CH"
#INCLUDE "APWEBEX.CH"
/*
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ EstqInfo ³ Autor ³Antonio Carlos Damaceno³ Data ³ 05/01/10 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ AdvPL que será requisitado via Socket-Client externo - VW  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ (Apenas adicionar ao repositorio e compilar)               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³                                                            ³±±
±±³          ³                                                            ³±±
±±³          ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Etka X Protheus                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

User Function EstqInfo()
// Resgata requisição da Browse ou Client-Socket

Local cGetPrdCod := ""
Local cRetText12 := ""
Local cData1     := ""
Local cData2     := ""
Local cData3     := ""
Local cTime1     := Substr(Time(),1,2)
Local cTime2     := Substr(Time(),4,2)
Local cTime3     := Substr(Time(),7,2)
Local cSign      := ""                     
Local cLocaliza  := ""
Local cB2QATU    := ""
Local lSBZ       := .F.
Local cQuery     := ""
Local cQAlSB     := "SQLSB"
Local cGruCatOri := ""
Local cEmpEtka   := HTTPGet->EMPRESA
Local cFilEtka   := HTTPGet->FILIAL
Local cTextEtka  := HTTPGet->PECA
//Conout(cEmpEtka)
//Conout(cFilEtka)
//Conout(cTextEtka)

If !Empty(cTextEtka)
	cGetPrdCod := cTextEtka
Else
	Return cRetText12
EndIf

// Prepara ambiente
RPCSetEnv(cEmpEtka,cFilEtka,,,,,{"SB1"}) 

lSBZ := ( SuperGetMV("MV_ARQPROD",.F.,"SB1") == "SBZ" )  //Determinar se procura pela SBZ ou SB5
cGruCatOri := GetNewPar("MV_GRUCATA","VW  ")

// Procura Produto pelo codigo da fabrica (B1_CODITE)
// Procura Localização do Produto e Qtde em Estoque
/*cQuery := "SELECT SB2.B2_QATU , "
If lSBZ .and. SBZ->(FieldPos("BZ_LOCALIZ")) > 0
	cQuery += "CASE WHEN SBZ.BZ_LOCALIZ IS NULL THEN SB5.B5_LOCALIZ ELSE SBZ.BZ_LOCALIZ END LOCALIZACAO "
	cQuery += "FROM "+RetSqlName("SB1")+" SB1 "
	cQuery += "LEFT JOIN "+RetSqlName("SB5")+" SB5 ON (SB5.B5_FILIAL='"+xFilial("SB5")+"' AND SB1.B1_COD=SB5.B5_COD AND SB5.D_E_L_E_T_=' ') "
	cQuery += "LEFT JOIN "+RetSqlName("SBZ")+" SBZ ON (SBZ.BZ_FILIAL='"+xFilial("SBZ")+"' AND SB1.B1_COD=SBZ.BZ_COD AND SBZ.D_E_L_E_T_=' ') "
Else
	cQuery += "SB5.B5_LOCALIZ AS LOCALIZACAO "
	cQuery += "FROM "+RetSqlName("SB1")+" SB1 "
	cQuery += "LEFT JOIN "+RetSqlName("SB5")+" SB5 ON (SB5.B5_FILIAL='"+xFilial("SB5")+"' AND SB1.B1_COD=SB5.B5_COD AND SB5.D_E_L_E_T_=' ') "
EndIf
cQuery += "JOIN "+RetSqlName("SB2")+" SB2 ON (SB2.B2_FILIAL='"+xFilial("SB2")+"' AND SB1.B1_COD=SB2.B2_COD "
cQuery += "AND SB2.B2_LOCAL BETWEEN '"+"01"+"' AND '"+"50"+"' AND SB2.D_E_L_E_T_=' ') "
cQuery += "WHERE SB1.B1_FILIAL='"+xFilial("SB1")+"' AND SB1.B1_CODITE='"+cGetPrdCod+"'  AND SB1.D_E_L_E_T_=' ' "
//cQuery += "AND SB1.B1_GRUPO = '"+cGruCatOri+"' "
cQuery += "GROUP BY LOCALIZACAO"*/

cQuery := "SELECT " 
cQuery += "  SUM(SB2.B2_QATU) QTDE , LOCALIZACAO "
cQuery += "FROM "
cQuery += "  "+RetSqlName("SB1")+" SB1 JOIN "+RetSqlName("SB2")+" SB2 ON "
cQuery += "    SB2.B2_FILIAL='"+xFilial("SB2")+"' AND SB1.B1_COD=SB2.B2_COD AND SB2.D_E_L_E_T_=' ' "
cQuery += "  JOIN "
cQuery += "    ( SELECT "
If lSBZ .and. SBZ->(FieldPos("BZ_LOCALIZ")) > 0
	cQuery += "       SB1.B1_COD, CASE WHEN SBZ.BZ_LOCALIZ IS NULL THEN SB5.B5_LOCALIZ ELSE SBZ.BZ_LOCALIZ END LOCALIZACAO "
	cQuery += "     FROM "
	cQuery += "       "+RetSqlName("SB1")+" SB1 LEFT JOIN "+RetSqlName("SB5")+" SB5 ON " 
	cQuery += "         SB5.B5_FILIAL='"+xFilial("SB5")+"' AND SB1.B1_COD=SB5.B5_COD AND SB5.D_E_L_E_T_=' ' "
	cQuery += "       LEFT JOIN "+RetSqlName("SBZ")+" SBZ ON "
	cQuery += "         SBZ.BZ_FILIAL='"+xFilial("SBZ")+"' AND SB1.B1_COD=SBZ.BZ_COD AND SBZ.D_E_L_E_T_=' ' "
Else
	cQuery += "       SB1.B1_COD, LOCALIZACAO "
	cQuery += "     FROM "
	cQuery += "       "+RetSqlName("SB1")+" SB1 LEFT JOIN "+RetSqlName("SB5")+" SB5 ON " 
	cQuery += "         SB5.B5_FILIAL='"+xFilial("SB5")+"' AND SB1.B1_COD=SB5.B5_COD AND SB5.D_E_L_E_T_=' ' "
EndIf
cQuery += "    ) TMP ON "
cQuery += "    SB1.B1_COD = TMP.B1_COD "
cQuery += "WHERE "
cQuery += "  SB1.B1_FILIAL='"+xFilial("SB1")+"' AND SB1.B1_CODITE='"+cGetPrdCod+"'  AND SB1.D_E_L_E_T_=' ' AND "
cQuery += "  SB1.B1_GRUPO = '"+cGruCatOri+"' AND "
cQuery += "  SB2.B2_LOCAL BETWEEN '01' AND '50' "
cQuery += "GROUP BY LOCALIZACAO "
dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ), cQAlSB, .F., .T. )

If (cQAlSB )->(Eof())
	cRetText12:=Replicate(" ", 81)+"Produto"+Replicate(" ", 13)+"Ñ Enctrado"
	( cQAlSB  )->( dbCloseArea() )
//	Conout("Nao achei o produto na select")
	Return cRetText12
EndIf
        
cLocaliza := LEFT((cQAlSB)->(LOCALIZACAO), 7)
cB2QATU   := strzero((cQAlSB)->(QTDE),6)
cSign     := IIf( (cQAlSB)->(QTDE)<0,"-","+")
cData1    := Substr(DtoC(dDatabase),1,2)
cData2    := Substr(DtoC(dDatabase),4,2)
cData3    := Substr(DtoC(dDatabase),7,4)
         
//Se estiver tudo Ok, gera texto de 240 caracteres para enviar para o Etka
cRetText12 := "001"                     //  1_3     3   Regiao
cRetText12 += "04872"                   //  4_8     5   Cod Concessionario
cRetText12 += "001"                     //  9_11    3   Cod Cia Alema
cRetText12 += "00"                      // 12_13    2
cRetText12 += "   "                     // 14_16    3
cRetText12 += cData1+cData2+cData3      // 17_24    8   Data Atual
cRetText12 += cTime1+cTime2+cTime3      // 25_30    6   Hota Atual
cRetText12 += "0"                       // 31_31    1
cRetText12 += SPACE(15)                 // 32_46   15
cRetText12 += " "                       // 47_47    1
cRetText12 += "31"                      // 48_49    2   *Tipo de Registro
cRetText12 += Replicate(" ", 10)        // 50_59   10
cRetText12 += "   "                     // 60_62    3
cRetText12 += "  "                      // 63_64    2
cRetText12 += "1 "                      // 65_66    2
cRetText12 += Replicate(" ", 14)        // 67_80   14   * Part Nr
cRetText12 += "1"                       // 81_81    1
cRetText12 += cSign                     // 82_82    1   *Sinal (+,-) Positivo/Negativo
cRetText12 += cB2QATU                   // 83_88    6   *Estoque   (B2_QATU)
cRetText12 += "0"                       // 89_89    1   Nr Casas decimais
cRetText12 += "       "                 // 90_96    7   (5,2) Preco Varejo
cRetText12 += "    "                    // 97_100   4   Estoque Minimo
cRetText12 += cLocaliza                 //101_110  10   *Localização da Peca no Estoque (B2_LOCAL)
cRetText12 += " "                       //111_111   1
cRetText12 += " "                       //112_112   1 
cRetText12 += " "                       //113_113   1
cRetText12 += " "                       //114_114   1
cRetText12 += "  "                      //115_116   2
cRetText12 += "1"                       //117_117   1
cRetText12 += Replicate(" ", 123)       //118_240 123   Espacos Vazios

( cQAlSB )->( dbCloseArea() )

//Conout(cRetText12)	

// Retorna dados formatados para o Etka
Return cRetText12




/*
;Configuração do TOTVS Application Server (totvsappserver.ini) para utilizar HTTP (boby etkaxprotheus)
[ONSTART]
JOBS=APW

[HTTP]
ENABLE=1
PATH=C:\P10R13\ProtQuadro 1 – Formas de obtenção do conhecimento Fonte: Orsi (2003)heus_Data\web
instances=20,200
PORT=81
 
[localhost:81]
enable=1
Cache-control=private
Pragma=no-cache
ResponseJob=APW
 
[APW] ; Configurações para Working Threads Extended
type=WEBEX
ONSTART=StartWebEx
ONCONNECT=ConnectWebEx
ONEXIT=FinishWebEx
instances=1,2
Environment=APTP10ANTONIO
; fim configuração para utilizar HTTP

*/
