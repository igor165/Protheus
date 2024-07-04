#INCLUDE "PROTHEUS.CH"
#INCLUDE "TBICONN.CH"
#INCLUDE "COLORS.CH"
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  | TMSR625  ³ Autor ³Andre Godoi            ³ Data ³25/03/10  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Impressao do Relatorio de Conhecimento de Transporte nao	  ³±±
±±³          ³autorizados e com algum tipo de erro ( Log de Rejeicao )    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³Nenhum                                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³Nenhum                                                      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
FUNCTION TMSR625()
Local cAliasDTP := ""
Local cAliasDT6 := ""
Local cNumLote  := ""
Local cQuery    := ""
Local cTitulo   := ""
Local cTitulo2  := ""
Local titulo    := "LOG de Rejeição - Conhecimento Eletrônico"
Local cString   := "DT6"
Local nomeprog  := "TMSR625"
Local cDesc1    := "Este programa tem como objetivo imprimir relatório "
Local cDesc2    := "de acordo com os parametros informados pelo usuário."
Local cDesc3    := ""
Local tamanho   := "G"
Local Cabec1    := ""
Local Cabec2    := ""
Local cPerg     := "TMR625A"
Local nCount    := 0
Local nQtdTot   := 0
Local nImp 		 := 0
Local limite    := 80
Local nTipo     := 18

Local aCTe      := {}
Local aLote     := {}
Local aDoctos 	 := {}
Local aHeader   := {}
Local aDACTE    := {}
Local aOrd      := {}
   
Local oDlg      := Nil   
Local oLbx      := Nil
Local oOk       := LoadBitMap( GetResources(),"LBOK")
Local oNo       := LoadBitMap( GetResources(),"LBNO")
Local oVerde	 := LoadBitmap( GetResources(),'BR_VERDE'		)
Local oAmarelo  := LoadBitmap( GetResources(),'BR_AMARELO'	)
Local oVermelho := LoadBitmap( GetResources(),'BR_VERMELHO'	)
Local oAzul     := LoadBitmap( GetResources(),'BR_AZUL'		)
Local oPreto	 := LoadBitmap( GetResources(),'BR_PRETO'		)
Local aAreaDTp  := DTP->( GetArea() )
Local lAbortPrint := .F.

PRIVATE wnrel   := "TMSR625" // Coloque aqui o nome do arquivo usado para impressao em disco
PRIVATE aReturn := { "Zebrado", 1, "Administracao", 2, 2, 1, "", 1}
PRIVATE nLastKey := 0

Cabec1 := "Filial  Serie  CT-e       Emissão     Remetente             Destinatario          No.Lote  Data/Hora Lote   Motivo"

Pergunte(cPerg,.F.)

wnrel := SetPrint(cString,NomeProg,cPerg,@titulo,cDesc1,cDesc2,cDesc3,.T.,aOrd,.T.,Tamanho,,.T.)

If nLastKey == 27
	Return
Endif

SetDefault(aReturn,cString)

If nLastKey == 27
   Return
Endif

nTipo := If(aReturn[4]==1,15,18)

RptStatus({|| TM625PRC(Cabec1,Cabec2,Titulo,80, tamanho, nomeprog, nTipo) },Titulo)

Return()

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³TMSCTERPT ³ Autor ³Adalberto SM              ³ Data ³16.04.2009³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Executar o Relatorio de LOG para Rejeicao do CTe              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ TMSCTERPT(Cabec1,Cabec2,Titulo,nLin, tamanho, nomeprog, nTipo)³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³          ³ 			                                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³                                                               ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
FUNCTION TM625PRC(Cabec1,Cabec2,Titulo,nLin, tamanho, nomeprog, nTipo)
Local cAliasDT6 := GetNextAlias() 	
Local nTotDoc   := 0
Private m_pag   := 01

cQuery := " SELECT DT6.DT6_FILDOC, "
cQuery += " DT6.DT6_SERIE , "
If SerieNfId("DT6",3,"DT6_SERIE")=="DT6_SDOC"
	cQuery += " DT6.DT6_SDOC, " 
EndIf
cQuery += " DT6.DT6_DOC   , "
cQuery += " DT6.DT6_DATEMI, "
cQuery += " DT6.DT6_CLIREM, "
cQuery += " DT6.DT6_LOJREM, "
cQuery += " DT6.DT6_CLIDES, "
cQuery += " DT6.DT6_LOJDES, "
cQuery += " DT6.DT6_RETCTE, "
cQuery += " DTP.DTP_LOTNFC, "
cQuery += " DTP.DTP_DATLOT, "
cQuery += " DTP.DTP_HORLOT  "
cQuery += " FROM " + RetSqlName('DT6') + " DT6, "
cQuery += "      " + RetSqlName('DTP') + " DTP  "
cQuery += " WHERE DT6.DT6_FILIAL = '" + xFilial('DT6') + "'"
cQuery += "   AND DT6.DT6_FILORI = '" + cFilAnt + "'"
cQuery += "   AND DT6.DT6_LOTNFC BETWEEN '"+mv_par01+"' AND '"+mv_par02+"'"
cQuery += "   AND DT6.DT6_DATEMI BETWEEN '"+Dtos(mv_par03)+"' AND '"+Dtos(mv_par04)+"'"
cQuery += "   AND DT6.DT6_PROCTE = ' '"
cQuery += "   AND DT6.DT6_DOCTMS <> '1'"
cQuery += "   AND DT6.DT6_IDRCTE NOT IN ('100','136')"
cQuery += "   AND DT6.DT6_SITCTE IN ( '3', '5' )"  
cQuery += "   AND DT6.D_E_L_E_T_ = ' '"
cQuery += "   AND DTP.DTP_FILORI = DT6_FILORI"
cQuery += "   AND DTP.DTP_LOTNFC = DT6_LOTNFC"
cQuery += "   AND DTP.DTP_TIPLOT IN ('3', '4') "
cQuery += "   AND DTP.D_E_L_E_T_ = ' '" 
cQuery += " ORDER BY DT6.DT6_FILDOC, DT6.DT6_DOC, DT6.DT6_SERIE "

cQuery := ChangeQuery(cQuery)

DbUseArea(.T., "TOPCONN", TCGenQry(,,cQuery), cAliasDT6, .F., .T.)

TcSetField(cAliasDT6,"DTP_DATLOT", "D", 8, 0)
TcSetField(cAliasDT6,"DT6_DATEMI", "D", 8, 0)

SetRegua(RecCount())
				
While (cAliasDT6)->(!Eof())
	IncRegua()

   //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
   //³ Verifica o cancelamento pelo usuario...                             ³
   //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
   If lAbortPrint
      @nLin,00 PSAY "*** CANCELADO PELO OPERADOR ***"
      Exit
   Endif

   //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
   //³ Impressao do cabecalho do relatorio. . .                            ³
   //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

   If nLin > 55 // Salto de Página. Neste caso o formulario tem 55 linhas...
      Cabec(Titulo,Cabec1,Cabec2,NomeProg,Tamanho,nTipo)
      nLin := 8
   Endif

	//         10        20        30        40        50        60         70       80        90       100       110         120       130
	//01234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012
	//Filial  Serie  CT-e       Emissão     Remetente             Destinatario          No.Lote  Data/Hora Lote   Motivo
	//XX      XXX    123456789  99/99/9999  12345678901234567890  12345678901234567890  123456   99/99/9999 99:99
	
	@ nLin, 000 PSay (cAliasDT6)->DT6_FILDOC
	@ nLin, 008 PSay SerieNfId((cAliasDT6),2,"DT6_SERIE")
	@ nLin, 015 PSay (cAliasDT6)->DT6_DOC
	@ nLin, 026 PSay (cAliasDT6)->DT6_DATEMI
	@ nLin, 038 PSay Padr(Posicione('SA1',1,xFilial('SA1')+(cAliasDT6)->(DT6_CLIREM+DT6_LOJREM),'A1_NREDUZ'),20)
	@ nLin, 060 PSay Padr(Posicione('SA1',1,xFilial('SA1')+(cAliasDT6)->(DT6_CLIDES+DT6_LOJDES),'A1_NREDUZ'),20)
	@ nLin, 082 PSay (cAliasDT6)->DTP_LOTNFC
	@ nLin, 091 PSay (cAliasDT6)->DTP_DATLOT
	@ nLin, 102 PSay (cAliasDT6)->DTP_HORLOT Picture "@R 99:99"
	@ nLin, 108 PSay Padr((cAliasDT6)->DT6_RETCTE,100)

   nLin    += 1
   nTotDoc += 1
	
  	(cAliasDT6)->(DbSkip())
EndDo

(cAliasDT6)->(DbCloseArea())
  						
@ nLin, 000 PSay Padr('Total de Documentos',107,'.')+' '+AllTrim(Transform(nTotDoc,'@E 999,999'))

SET DEVICE TO SCREEN

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Se impressao em disco, chama o gerenciador de impressao...          ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

If aReturn[5]==1
   dbCommitAll()
   SET PRINTER TO
   OurSpool(wnrel)
Endif

MS_FLUSH()

Return()