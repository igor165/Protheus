#INCLUDE "plsr674.ch"
#include "PROTHEUS.CH"
#include "PLSMGER.CH" 
#define __SIZEACURRCRI {0,0}                  
//pos[1] - notas criticadas                                          
//pos[2] - itens criticados
#define __SIZEACURREMP {0,0,0,0}                  
//pos[1] - tot pago                                          
//pos[2] - tot apre
//pos[3] - tot contr
//pos[4] - tot dif
#define __SIZEACURRGUI {0,0,0,0,0,0,0,0,0,0}      
//pos[1] - tot pago                                          
//pos[2] - tot apre
//pos[3] - tot contr
//pos[4] - tot dif
//pos[5] - tot itens
//pos[6] - tot subitens
//pos[7] - tot tx pago 
//pos[8] - tot tx apre
//pos[9] - tot tx contr 
//pos[10]- tot tx dif
#define __SIZEPARAMGUI {0,0,0,0,0}
//pos[1] - tot qtd
//pos[2] - tot pago
//pos[3] - tot apre
//pos[4] - tot contr
//pos[5] - tot dif

// guia de servico/consulta/gih  
// tot notas,tot itens,tot subitens,tot pago,tot apr,tot contr,tot glo 
// {0,0,0,0,0,0,0,
           				
Static aVet := 	 {0,;   // total pago
  				  0,;   // total apresentado
           		  0,;   // total contratado
           		  0,;   // total glosado
          		  		{0,0,0,0,0,0,0,{__SIZEPARAMGUI,;  // r$
           						  		__SIZEPARAMGUI,;  // ch
           						  		__SIZEPARAMGUI,;  // m2
           						  		__SIZEPARAMGUI,;  // proc
           						  		__SIZEPARAMGUI,;  // mat
           						  		__SIZEPARAMGUI,;  // med
           						  		__SIZEPARAMGUI,;  // taxa
           						  		__SIZEPARAMGUI,;  // diar
           						  		__SIZEPARAMGUI,;  // ortpro
           						  		__SIZEPARAMGUI,;  // admni
           						  		}},;    
           				{0,0,0,0,0,0,0,{__SIZEPARAMGUI,;
           		  				  		__SIZEPARAMGUI,;
           		  				  		__SIZEPARAMGUI,;
           		  				  		__SIZEPARAMGUI,;
           		  				  		__SIZEPARAMGUI,;
           		  				  		__SIZEPARAMGUI,;
           		  				  		__SIZEPARAMGUI,;
           		  				  		__SIZEPARAMGUI,;
           		  				  		__SIZEPARAMGUI,;
           		  				  		__SIZEPARAMGUI}},;        
           				{0,0,0,0,0,0,0,{__SIZEPARAMGUI,;
           								__SIZEPARAMGUI,;
           						  		__SIZEPARAMGUI,;
           						  		__SIZEPARAMGUI,;
           						  		__SIZEPARAMGUI,;
           						  		__SIZEPARAMGUI,;
           						  		__SIZEPARAMGUI,;
           						  		__SIZEPARAMGUI,;
           						  		__SIZEPARAMGUI,;
           						  		__SIZEPARAMGUI}}} 

Static aCurrent := {__SIZEACURREMP,; // totais da empresa corrente
					__SIZEACURRGUI,; // totais da guia corrente
					__SIZEACURREMP,; // totais por tipo de guia
					__SIZEACURREMP}	 // totais por (pago,glosado,reconsiderado)
Static aCriticas:= {__SIZEACURRCRI}

Static objCENFUNLGP := CENFUNLGP():New()
Static lAutoSt := .F.

/*/
ээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээ
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
╠╠зддддддддддбдддддддддбдддддддбддддддддддддддддддддддддбддддддбдддддддддд©╠╠╠
╠╠ЁFuncao    Ё PLSR674 Ё Autor Ё Daher			        Ё Data Ё 03.07.05 Ё╠╠╠
╠╠цддддддддддедддддддддадддддддаддддддддддддддддддддддддаддддддадддддддддд╢╠╠╠
╠╠ЁDescricao Ё Extrato de Movimentacao Importada                          Ё╠╠╠
╠╠цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢╠╠╠
╠╠ЁSintaxe   Ё PLSR674()                                                  Ё╠╠╠
╠╠цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢╠╠╠
╠╠Ё Uso      Ё Advanced Protheus                                          Ё╠╠╠
╠╠цддддддддддадддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢╠╠╠
╠╠Ё Alteracoes desde sua construcao inicial                               Ё╠╠╠
╠╠цддддддддддбддддддбдддддддддддддбддддддддддддддддддддддддддддддддддддддд╢╠╠╠
╠╠Ё Data     Ё BOPS Ё Programador Ё Breve Descricao                       Ё╠╠╠
╠╠цддддддддддеддддддедддддддддддддеддддддддддддддддддддддддддддддддддддддд╢╠╠╠
╠╠юддддддддддаддддддадддддддддддддаддддддддддддддддддддддддддддддддддддддды╠╠╠
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
ъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъ
/*/

Function PLSR674(lAuto)
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Define variaveis padroes para todos os relatorios...                     Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
LOCAL lGerTxt1      := .F.
LOCAL aDadBD7BDX    := {}
LOCAL lBD7_VLTXPG 	:= BD7->(FieldPos("BD7_VLTXPG")) > 0
LOCAL lBD7_VLRGTX 	:= BD7->(FieldPos("BD7_VLRGTX")) > 0
PRIVATE lGerTxt     := lGerTxt1
Private cRelDir     := GetMv("MV_RELT") 
PRIVATE nQtdLin
PRIVATE cNomeProg   := "PLSR674"
PRIVATE nCaracter   := 15
PRIVATE nLimite     := 132
PRIVATE cTamanho    := "M"
PRIVATE cTitulo     := FunDesc() //"ConferЙncia de Pagamento de IntercБmbio"
PRIVATE cDesc1      := STR0002 //"Emite o extrato de servicos prestados pela RDA"
PRIVATE cDesc2      := ""
PRIVATE cDesc3      := ""
PRIVATE cAlias      := "BD7"
PRIVATE cPerg       := "PLR674"
PRIVATE nRel        := "PLSR674"
PRIVATE m_pag       := 1
PRIVATE lCompres    := .F.
PRIVATE lDicion     := .F.
PRIVATE lFiltro     := .T.
PRIVATE lCrystal    := .F.
PRIVATE aOrderns    := {}
PRIVATE aReturn     := { STR0003, 1,STR0004, 1, 1, 1, "",1 } //"Zebrado"###"Administracao"
PRIVATE lAbortPrint := .F.
PRIVATE cCabec1     := ""
PRIVATE cCabec2     := ""
PRIVATE nColuna     := 00
PRIVATE nLi         := 0
PRIVATE nLinPag     := 65
PRIVATE pMoeda1     := "@E 999,999.99"
PRIVATE pMoeda2     := "@E 999,999,999.99"
PRIVATE nTamDes     := 35
PRIVATE cSituac		:= "1"
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Parametros do relatorio (SX1)...                                         Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
PRIVATE nTipImp
PRIVATE cCodOpe
PRIVATE cRda 
PRIVATE cAno   
PRIVATE cMes   
PRIVATE cPegDe 
PRIVATE cPegAte
PRIVATE nTipQbc
PRIVATE nTipRel
PRIVATE nFase  
PRIVATE nNumImp
PRIVATE nImpBlq
PRIVATE cClaPre
PRIVATE cNumFat
PRIVATE lImpZero
PRIVATE cLoteImp
PRIVATE lContMaM
PRIVATE nPerTx
PRIVATE cTipoSc
PRIVATE cTipoGl
PRIVATE cTipoRe
PRIVATE lMatAnt
PRIVATE lImpCon
PRIVATE lImpPre
PRIVATE lImpGui
PRIVATE lImpCri

Default lAuto := .F.

lAutoSt := lAuto

//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Chama SetPrint                                                           Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
If !lauto
	nRel := SetPrint(cAlias,nRel,cPerg,@cTitulo,cDesc1,cDesc2,cDesc3,lDicion,aOrderns,lCompres,cTamanho,{},lFiltro,lCrystal,,lGerTXT)
endIf
	aAlias := {"BA0","SE1","BRJ","BAG","BAU"}
	objCENFUNLGP:setAlias(aAlias)

//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Verifica se foi cancelada a operacao                                     Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
If !lauto .AND. nLastKey  == 27
    Return
Endif
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Acessa parametros do relatorio...                                        Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
Pergunte(cPerg,.F.)
If lauto
	mv_par12 := 0
	mv_par16 := 0
	mv_par17 := 0
	mv_par18 := 0
	mv_par19 := 0
	mv_par20 := 0
	mv_par21 := 1
	mv_par22 := "030"
	mv_par06 := " "
	mv_par07 := "ZZZZZZZZ"
	mv_par02 := "0001"
	mv_par03 := "000006"
	mv_par05 := "12"
	mv_par04 := "2020"
	mv_par09 := 4
endIf

nTipImp   := mv_par01
cCodOpe   := mv_par02
cRda      := mv_par03
cAno      := mv_par04
cMes      := mv_par05  
cPegDe    := mv_par06
cPegAte   := mv_par07
nTipQbc   := mv_par08
nFase     := mv_par09
cNumFat   := mv_par10
cLoteImp  := mv_par11
lImpCrit  := if(mv_par12==1,.T.,.F.)
cTipoSc   := mv_par13 					// 1-Serv sem criticas
cTipoGl   := mv_par14 		   			// 2-Serv glosados
cTipoRe   := mv_par15 					// 3-Serv reconciderados
lMatAnt   := Iif(mv_par16==1,.T.,.F.) // Se imprime a matricula antigo ou a atual
lImpCon   := Iif(mv_par17==1,.T.,.F.) // Se imprime o relatorio de contestacao junto
lImpGui   := Iif(mv_par18==1,.T.,.F.) // Se imprime Numero da Guia
lImpPre   := Iif(mv_par19==1,.T.,.F.) // Se imprime Numero do Impresso
lImpRec   := Iif(mv_par20==1,.T.,.F.) // Se imprime somente glosados
cSituac   := AllTrim( Str(mv_par21) )  // Situacao da guia
cCritica  := AllTrim(PLSCRITIC(@mv_par22,.F.)) // Criticas que vao ser exibidas
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Se nao existir esta critica cria										 Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
PLSPOSGLO(PLSINTPAD(),'541','Nao foi encontrado o registro na tabela de Glosa de Movimentacao')
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Analise de criticas entre o bd7 e o bdx									 Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
cSql := " SELECT BD7.BD7_CODOPE,BD7.BD7_CODLDP,BD7.BD7_CODPEG,BD7.BD7_NUMERO,BD7.BD7_SEQUEN,BD7_VLRGLO, "
cSql += "        BD7.BD7_CODPAD,BD7.BD7_CODPRO,BD7.BD7_ORIMOV, "
cSql += "        BD7.BD7_VLRGLO,BD7.BD7_VLRPAG,BD7.BD7_VLRGLO,BD7.BD7_TIPREG,BD7.BD7_VLRPAG, "
cSql += "        BD7.BD7_VLRAPR,BD7.BD7_VALORI,BD7.BD7_VLRMAN,BD7.BD7_VLRBPR "

if lBD7_VLTXPG .and. lBD7_VLRGTX
	cSql += "   ,BD7.BD7_VLRGTX,BD7.BD7_VLTXPG "
endIf

cSql += " FROM "+BD7->(RetSQLName("BD7"))+" BD7 "
cSql += " WHERE NOT EXISTS (SELECT BDX_CODOPE,BDX_CODLDP,BDX_CODPEG,BDX_NUMERO,BDX_ORIMOV,BDX_CODPAD,BDX_CODPRO,BDX_SEQUEN "
cSql += " 			  		FROM "+BDX->(RetSQLName("BDX"))+" "
cSql += " 				    WHERE BDX_FILIAL = '" + xFilial("BDX") + "' "  
cSql += " 				    AND BDX_CODOPE = BD7.BD7_CODOPE " 
cSql += " 					AND BDX_CODLDP = BD7.BD7_CODLDP "
cSql += " 					AND BDX_CODPEG = BD7.BD7_CODPEG "
cSql += " 					AND BDX_NUMERO = BD7.BD7_NUMERO "
cSql += " 					AND BDX_ORIMOV = BD7.BD7_ORIMOV "
cSql += " 					AND BDX_CODPAD = BD7.BD7_CODPAD "
cSql += " 					AND BDX_CODPRO = BD7.BD7_CODPRO "
cSql += " 					AND BDX_SEQUEN = BD7.BD7_SEQUEN "
cSql += " 					AND "+BDX->(RetSQLName("BDX"))+".D_E_L_E_T_ <> '*') "
cSql += " AND BD7.BD7_VLRGLO > 0 "
cSql += " AND BD7.D_E_L_E_T_ <> '*' "
cSql += " AND BD7_FILIAL = '" + xFilial("BD7")	+ "' "  
cSql += " AND BD7_CODOPE = '" + cCodOpe 	    + "' "
cSql += " AND BD7_CODRDA = '" + cRda    	    + "' "
cSql += " AND BD7_CODPEG BETWEEN '" + cPegDe   + "' AND '" + cPegAte + "' "

PLSQUERY(cSQL,"TrbBD7BDX")

//Monta array para exibir na crigen										 
While !TrbBD7BDX->( Eof() )    
    BDX->(RecLock("BDX",.T.))
	    BDX->BDX_FILIAL := xFilial("BDX")
	    BDX->BDX_IMGSTA := "BR_VERMELHO"
	    BDX->BDX_CODOPE := TrbBD7BDX->BD7_CODOPE
	    BDX->BDX_CODLDP := TrbBD7BDX->BD7_CODLDP
	    BDX->BDX_CODPEG := TrbBD7BDX->BD7_CODPEG
	    BDX->BDX_NUMERO := TrbBD7BDX->BD7_NUMERO
	    BDX->BDX_NIVEL  := "1"
	    BDX->BDX_CODPAD := TrbBD7BDX->BD7_CODPAD
	    BDX->BDX_CODPRO := TrbBD7BDX->BD7_CODPRO
	    BDX->BDX_DESPRO := BR8->(Posicione("BR8",1,xFilial("BR8")+TrbBD7BDX->(BD7_CODPAD+BD7_CODPRO),"BR8_DESCRI"))
	    BDX->BDX_SEQUEN := TrbBD7BDX->BD7_SEQUEN
	    BDX->BDX_CODGLO := "541"
	    BDX->BDX_GLOSIS := "541"
	    BDX->BDX_DESGLO := STR0005 //"Nao foi encontrado o registro em Glosas das Movimentacoes"
	    BDX->BDX_INFGLO := ""
	    BDX->BDX_TIPGLO := "1"           
	    BDX->BDX_ORIMOV := TrbBD7BDX->BD7_ORIMOV
	    
	    BDX->BDX_PERGLO := round( ( TrbBD7BDX->BD7_VLRGLO / (TrbBD7BDX->BD7_VLRMAN + TrbBD7BDX->BD7_VLRGLO) ) * 100, 2)
	    BDX->BDX_VLRGLO := TrbBD7BDX->BD7_VLRGLO

	    if lBD7_VLTXPG .and. lBD7_VLRGTX
			BDX->BDX_PERGTX := round ( ( TrbBD7BDX->BD7_VLRGTX / (TrbBD7BDX->BD7_VLTXPG + TrbBD7BDX->BD7_VLRGTX) ) * 100, 2)
			BDX->BDX_VLRGTX := TrbBD7BDX->BD7_VLRGTX
	    endIf
	    
	    BDX->BDX_RESPAL := ""
	    BDX->BDX_TIPREG := TrbBD7BDX->BD7_TIPREG
	    BDX->BDX_VLRPAG := TrbBD7BDX->BD7_VLRPAG
	    BDX->BDX_VLRAPR := TrbBD7BDX->BD7_VLRAPR
	    BDX->BDX_VLRMAN := TrbBD7BDX->BD7_VLRMAN
	    BDX->BDX_VLRBPR := TrbBD7BDX->BD7_VLRBPR
    BDX->( MsUnLock() )
	AaDd(aDadBD7BDX,{TrbBD7BDX->BD7_CODLDP,TrbBD7BDX->BD7_CODPEG,TrbBD7BDX->BD7_NUMERO,TrbBD7BDX->BD7_SEQUEN,TrbBD7BDX->BD7_VLRGLO} )
TrbBD7BDX->( DbSkip() )
EndDo
TrbBD7BDX->( DbCloseArea() )
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Exibe resultado														     Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
If !lauto .AND. Len(aDadBD7BDX) > 0   
   PLSCRIGEN(aDadBD7BDX,{ {"Lod Dig.","@C",50}, {"Peg.","@C",50 },{"Guia","@C",50 }, {"Sequencia","@C",50 }, {"Valor Glosa","@E 999,999,999.99",50 } },"Critica de Evento x Glosa da Movimentacao")
EndIf

cTitulo   += RetMesAno(cAno+cMes)
If Empty(cLoteImp) .And. Empty(cNumFat)
   If !lauto
   	MsgAlert(STR0006) //"Informe o Nro do Lote Pagto e/ou Lote de Importacao!"
   endif
   Return
EndIf                                        
/*       10        20        30        40        50        60        70        80        90       100       110       120       130       140       150       160       170       180       190       200       210       220
1234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890*/
If  nTipQbc == 1
    cCabec1 := "Matricula              Nome"              
    cCabec2 := "Nro.Guia  Nro.Peg             Cod.Proced.     Descricao"
Endif
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Configura impressora                                                     Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
if !lauto
	SetDefault(aReturn,cAlias)
	//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	//Ё Emite relat╒rio                                                          Ё
	//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
	MsAguarde({|| R674Imp() }, cTitulo, "", .T.)
else
	R674Imp()
endIf
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Fim da rotina                                                            Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
Return
/*/
ээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээ
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
╠╠здддддддддддбддддддддддбдддддддбдддддддддддддддддддддддбддддддбдддддддддд©╠╠
╠╠ЁPrograma   Ё R674Imp  Ё Autor Ё Daher			     Ё Data Ё 03.07.05 Ё╠╠
╠╠цдддддддддддеддддддддддадддддддадддддддддддддддддддддддаддддддадддддддддд╢╠╠
╠╠ЁDescricao  Ё Imprime o extrato mensal dos servicos prestados            Ё╠╠
╠╠юдддддддддддадддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды╠╠
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
/*/
Static Function R674Imp()
LOCAL cSQL       := ""
LOCAL cChaveEmp  := ""
LOCAL cChaveUsu  := ""
LOCAL cChaveBD6  := ""
LOCAL cChaveBD7  := ""       
LOCAL cChaveOrd  := ""
LOCAL aRet 		 := {}        
LOCAL aProcs	 := {}
LOCAL cTipGui	 := ""       
LOCAL aMatAux  	 := {{},{},{}}
LOCAL nY		 := 0
LOCAL cMsgOrd	 := ""
LOCAL nI		 := 0 
PRIVATE cBDXAcao := "0"
PRIVATE aMatCot  := {}
PRIVATE nOrdem   := 0   
PRIVATE aMatBD6  := {}
aMatAux[1]  := {}
aMatAux[2]  := {}
aMatAux[3]  := {}
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Exibe mensagem...                                                        Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
If !lAutoSt
//	nOrdem := 1
	MsProcTxt(STR0007) //"Processando ..."
endIf
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Monta indregua no BD7                                                    Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды                                      
cSql := " SELECT BD6_FILIAL,BD6_OPEORI,BD6_CODEMP,BD6_TIPGUI,BD6_CODPEG,BD6_NUMERO,BD6_NUMIMP,BD6_MATRIC,BD6_DATPRO,BD6_SEQUEN,"
cSql += " BD6_ORIMOV,BD6_SITUAC,BD6_FASE,BD6_CODPAD,BD6_CODPRO,BD6_TIPREG,BD6_QTDPRO,BD6_CODOPE,BD6_CODLDP,BD6_MATANT,BD6_DIGITO,BD6_NOMUSR,BD6_SOLORI,BD6_VLRGLO "
cSql += " FROM " + RetSqlName("BD6") + " WHERE "
cSql += " BD6_FILIAL = '" + xFilial("BD6")	+ "' AND "  
cSql += " BD6_CODOPE = '" + cCodOpe 	   	+ "' AND "
cSql += " BD6_CODRDA = '" + cRda    	   	+ "' AND "
cSql += " BD6_CODPEG BETWEEN '"+ cPegDe		+ "' AND '" + cPegAte + "' AND "
cSql += " BD6_TIPGUI IN ('01','02', '03', '05') AND "
If  ! Empty(cNumFat) .And. nFase == 2 //1=Pronta;2=Faturada;3=Conferencia;4=Todas
    cSql += " BD6_OPELOT = '"+cCodOpe+"' AND BD6_NUMLOT = '"+cNumFat+"' AND "
Else
    If  nFase == 2
        cSql += " BD6_OPELOT = '"+cCodOpe+"' AND SUBSTRING(BD6_NUMLOT,1,6) = '"+cAno+cMes+"' AND "
    Else
		cSql += " BD6_ANOPAG = '" + cAno + "' AND "
		cSql += " BD6_MESPAG = '" + cMes + "' AND "
    Endif
Endif
If     nFase == 1
       cSql += " BD6_FASE = '3' AND BD6_SITUAC = '"+cSituac+"' AND"
ElseIf nFase == 2
	   cSql += " BD6_FASE = '4' AND BD6_SITUAC = '"+cSituac+"' AND"
ElseIf nFase == 3
	   cSql += " BD6_FASE = '2' AND BD6_SITUAC = '"+cSituac+"' AND"
ElseIf nFase == 4                                                                             
	   cSql += " (BD6_FASE = '1' Or BD6_FASE = '2' Or BD6_FASE = '3' Or BD6_FASE = '4') AND BD6_SITUAC = '"+cSituac+"' AND"
Endif                                                    
cSql += " D_E_L_E_T_ <> '*' "
If ! Empty(cLoteImp)
	if BD6->(FieldPos("BD6_SEQIMP")) > 0
		cSql += " AND BD6_SEQIMP = '"+AllTrim(cLoteImp)+"'"
	endif
Endif
If lImpRec
   cSql += " AND BD6_VLRGLO > 0 "
EndIf
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Monta ordem                                                              Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды                
cSql += " ORDER BY BD6_FILIAL,BD6_OPEORI,BD6_CODEMP,BD6_TIPGUI,BD6_CODPEG,BD6_NUMERO,BD6_MATANT,BD6_DATPRO,BD6_SEQUEN "
PLSQUERY(cSQL,"TrbBD6")
TrbBD6->(DbGoTop())
lFirst  := .T.  
If  !TrbBD6->(Eof())    
	//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	//Ё Posiciona na RDA														 Ё
	//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
	BAU->(DbSetOrder(1))
	If ! BAU->(MsSeek(xFilial("BD6")+cRda))                                                    
	   If !lautoSt
		MsgAlert(STR0008+cRda) //"Nao foi possivel localizar rda "
	   endIf
	Endif   
	//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	//Ё Inicia o loop para montar a matriz										 Ё
	//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
	While !TrbBD6->( Eof() )     
	    nI++  
		If !lautoSt
			MsProcTXT(STR0009 + TrbBD6->BD6_CODEMP + STR0010 + StrZero(nI,6) ) //"Gerando ->"###" Reg N.: "
			ProcessMessage()
		endIf
		
		If TrbBD6->BD6_TIPGUI $ '03,05'               
		   //BE4_FILIAL + BE4_CODOPE + BE4_CODLDP + BE4_CODPEG + BE4_NUMERO + BE4_SITUAC + BE4_FASE
		   cAlias := 'BE4'
		Else
		   //BD5_FILIAL + BD5_CODOPE + BD5_CODLDP + BD5_CODPEG + BD5_NUMERO + BD5_SITUAC + BD5_FASE + dtos(BD5_DATPRO) + BD5_OPERDA + BD5_CODRDA                                                               
		   cAlias := 'BD5'
		EndIf	                
		//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
		//Ё Verifica a Ordem 														 
		//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
		If TrbBD6->(BD6_CODOPE+BD6_CODLDP+BD6_CODPEG+BD6_NUMERO+BD6_SITUAC+BD6_FASE) <> cChaveOrd .Or. TrbBD6->BD6_TIPGUI <> cTipGui

			cChaveOrd := TrbBD6->(BD6_CODOPE+BD6_CODLDP+BD6_CODPEG+BD6_NUMERO+BD6_SITUAC+BD6_FASE)
			cTipGui   := TrbBD6->BD6_TIPGUI 
			
		    &(cAlias+"->(DbSetOrder(1))")
			If &(cAlias+"->( MsSeek(xFilial('"+cAlias+"')+TrbBD6->(BD6_CODOPE+BD6_CODLDP+BD6_CODPEG+BD6_NUMERO+BD6_SITUAC+BD6_FASE) ) )")

			   If &(cAlias+"->"+cAlias+"_VLRPAG") > 0 .And. &(cAlias+"->"+cAlias+"_VLRGLO") == 0
	                nOrdem := 1  // Pago
			   ElseIf &(cAlias+"->"+cAlias+"_VLRPAG") == 0 .And. &(cAlias+"->"+cAlias+"_VLRGLO") > 0
	                nOrdem := 2  //Glosado
	                cBDXAcao := "1"
			   ElseIf &(cAlias+"->"+cAlias+"_VLRPAG") > 0 .And. &(cAlias+"->"+cAlias+"_VLRGLO") > 0
	                nOrdem := 3  //Reconsiderado
	                cBDXAcao := "2"
			   Else                                      
					TrbBD6->(DbSkip())
			        Loop
			        nOrdem := 2 //Glosado
			   EndIF
			Else
				If !lautoSt
					MsgAlert(STR0011+cAlias+STR0012+TrbBD6->(BD6_CODOPE+BD6_CODLDP+BD6_CODPEG+BD6_NUMERO) )    //"Base inconsistente BD6 sem "###" na Chave: "
				endIf
				Exit
			EndIf                                                                                       
		EndIf	

		If !(lautoSt .AND. nOrdem == 0)
			AaDd(aMatAux[nOrdem],{	TrbBD6->BD6_FILIAL,; //1
								TrbBD6->BD6_OPEORI,; //2
								TrbBD6->BD6_CODEMP,; //3
					   			TrbBD6->BD6_TIPGUI,; //4
								TrbBD6->BD6_CODPEG,; //5
								TrbBD6->BD6_NUMERO,; //6
								TrbBD6->BD6_MATRIC,; //7
								TrbBD6->BD6_DATPRO,; //8
								TrbBD6->BD6_SEQUEN,; //9
								TrbBD6->BD6_ORIMOV,; //10
								TrbBD6->BD6_SITUAC,; //11
								TrbBD6->BD6_FASE,  ; //12
					   			TrbBD6->BD6_CODPAD,; //13
								TrbBD6->BD6_CODPRO,; //14
								TrbBD6->BD6_TIPREG,; //15
					   			TrbBD6->BD6_QTDPRO,; //16
								TrbBD6->BD6_CODOPE,; //17
								TrbBD6->BD6_CODLDP,; //18                                        
								TrbBD6->BD6_NUMIMP,; //19                                        
								TrbBD6->BD6_MATANT,; //20
								TrbBD6->BD6_DIGITO,; //21
								TrbBD6->BD6_NOMUSR,; //22
								StrTran(Left(TrbBD6->BD6_SOLORI,4)," ","X"),; // 23
								TrbBD6->BD6_VLRGLO}) //24
		endIf
		TrbBD6->(DbSkip())
	EndDo
Else
	TrbBD6->(DbCloseArea())
	If !lAutoSt
		MsgAlert(STR0013) //"Nao foram encontrados dados na base dados."
	endIf
	Return
EndIf	            
TrbBD6->(DbCloseArea())
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Imprime dados da RDA                                                     Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
R674RDA() 	    
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Inicia a leitura da matriz											     Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
nOrdem := 0
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Seta ordem para o bdx													 Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
BDX->( DbSetOrder(1) )//BDX_FILIAL+BDX_CODOPE+BDX_CODLDP+BDX_CODPEG+BDX_NUMERO+BDX_ORIMOV+BDX_CODPAD+BDX_CODPRO+BDX_SEQUEN+BDX_CODGLO
For nY := 1 To 3       
	aMatBD6 := {}
	lFirst  := .T.
	If nY == 1	.And.  cTipoSc == 1  //Pago
	     aMatBD6 := aClone( aMatAux[nY] )
	     cMsgOrd := 'Pagamento'
	ElseIf nY == 2	.And. cTipoGl == 1 //Glosado
	     aMatBD6  := aClone( aMatAux[nY] )
	     cMsgOrd  := 'Glosado'
	ElseIf nY == 3	.And. cTipoRe == 1  //Recosiderado
	     aMatBD6  := aClone( aMatAux[nY] )
	     cMsgOrd  := 'Reconsiderado'
	EndIf         
	//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	//Ё Mostra tipo de ordem													 Ё
	//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
	if nY == 2 .Or. !lImpRec
		If !Empty(aMatBD6)
			R674Linha(Replicate('-',nLimite),1,0)
			R674Linha(cMsgOrd ,1,0)
			If !lFirst
				R674Linha(Replicate('-',nLimite),1,0)
			EndIf
		EndIf
	Endif
	For nI := 1 To Len(aMatBD6)
		
		If !lautost
			MsProcTXT(STR0014+cMsgOrd+"-> "+aMatBD6[nI,3]+STR0010+StrZero(nI,6)+" - "+StrZero(Len(aMatBD6),6) ) //"Imp. "###" Reg N.: "
			ProcessMessage()
		endIf

		If lFirst
			
			if (nY == 2 .or. nY == 3) .Or. !lImpRec
				
				PlsTotali("1",nil,aMatBD6[nI,4],nil,aProcs)
				//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
				//Ё Empresa																   Ё
				//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
				PlsImpEmp(nI)
				//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
				//Ё Imprime tipo de Guia													   Ё
				//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
				PlsImpTpG(1,nI)
				
				//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
				//Ё Usuario																   Ё
				//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
				aProcs := PlsImpUsr(.F.,CTipGui,nI)
				If Len(aProcs) == 0
					PlsTotali("-1",nil,aMatBD6[nI,4],nil,aProcs)
				EndIf
				//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
				//Ё Lot e Ser																   Ё
				//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
				PlsImpLot(aProcs,nI)
				PlsImpSer(aProcs,nI)
			Endif
		Endif
		
		if (nY == 2 .or. nY == 3) .Or. !lImpRec
			//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
			//Ё Chaves de pesquisa		                                               Ё
			//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
			cChaveEmp  := aMatBD6[nI,1]+aMatBD6[nI,17]+aMatBD6[nI,3]
			cChaveUsu  := aMatBD6[nI,1]+aMatBD6[nI,17]+aMatBD6[nI,3]+aMatBD6[nI,3]+aMatBD6[nI,15]
			cChaveBD6  := aMatBD6[nI,1]+aMatBD6[nI,17]+aMatBD6[nI,18]+aMatBD6[nI,5]+aMatBD6[nI,6]
			//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
			//Ё Posiciona no BD7														   Ё
			//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
			BD7->( DbSetOrder(1) )
			BD7->( MsSeek( xFilial("BD7")+aMatBD6[nI,17]+aMatBD6[nI,18]+aMatBD6[nI,5]+aMatBD6[nI,6]+aMatBD6[nI,10]+aMatBD6[nI,9] ) )
			
			If ! BD7->(Found()) .AND. !lautoSt
				MsgStop(STR0015+xFilial("BD7")+aMatBD6[nI,17]+aMatBD6[nI,18]+aMatBD6[nI,5]+aMatBD6[nI,6]+aMatBD6[nI,10]+aMatBD6[nI,9] ) //"Nao foi possivel localizar bd7 "
			Endif
			
			cChaveBD7  := aMatBD6[nI,1]+aMatBD6[nI,17]+aMatBD6[nI,18]+aMatBD6[nI,5]+aMatBD6[nI,6]+aMatBD6[nI,10]+aMatBD6[nI,9]
			//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
			//Ё Processa os subitens		                                               Ё
			//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
			aRet := PLSImpBD7(cChaveBD7,aCurrent,aProcs,nI)
			//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
			//Ё Totais																   Ё
			//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
			PlsTotali("2",aRet,aMatBD6[nI,4],aCurrent,aProcs)
			//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
			//Ё Proximo item				                                               Ё
			//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
			cTipGui := aMatBD6[nI,4]
			nI++
			//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
			//Ё Mudou a empresa				                                           Ё
			//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
			If   nI <= Len(aMatBD6) .And. cChaveEmp <> aMatBD6[nI,1]+aMatBD6[nI,17]+aMatBD6[nI,3]
				//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
				//Ё Total Guia Anterior													  Ё
				//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
				PlsTotali("3",nil,cTipGui,aCurrent,aProcs)
				//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
				//Ё Total Guia Proxima													   Ё
				//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
				PlsTotali("1",nil,aMatBD6[nI,4],nil,aProcs)
				//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
				//Ё Taxa																	   Ё
				//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
				PlsImpTax(cChaveBD6,aProcs)
				//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
				//Ё Total Tipo Guia														   Ё
				//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
				PlsImpTTG(cTipGui,nI)
				//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
				//Ё Total Emp																   Ё
				//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
				PlsImpTEm()
				//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
				//Ё Empresa																   Ё
				//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
				PlsImpEmp(nI)
				//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
				//Ё Imp tipo de Guia														   Ё
				//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
				PlsImpTpG(1,nI)
				//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
				//Ё Usuario																   Ё
				//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
				aProcs := PlsImpUsr(.F.,cTipGui,nI)
				if Len(aProcs) == 0
					PlsTotali("-1",nil,aMatBD6[nI,4],nil,aProcs)
				endif
				//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
				//Ё Lot e Ser																   Ё
				//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
				PlsImpLot(aProcs,nI)
				PlsImpSer(aProcs,nI)
				//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
				//Ё Mudou a guia				                                               Ё
				//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
			Elseif nI <= Len(aMatBD6) .And. (cChaveUsu <> aMatBD6[nI,1]+aMatBD6[nI,17]+aMatBD6[nI,3]+aMatBD6[nI,3]+aMatBD6[nI,15] .or.;
				cChaveBD6 <> aMatBD6[nI,1]+aMatBD6[nI,17]+aMatBD6[nI,18]+aMatBD6[nI,5]+aMatBD6[nI,6] )
				//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
				//Ё Total Guia Anterior													   Ё
				//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
				PlsTotali("3",nil,cTipGui,aCurrent,aProcs)
				//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
				//Ё Total Guia Proxima													   Ё
				//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
				PlsTotali("1",nil,aMatBD6[nI,4],nil,aProcs)
				//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
				//Ё Taxa																	   Ё
				//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
				PlsImpTax(cChaveBD6,aProcs)
				//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
				//Ё Se mudou o tipo de guia												   Ё
				//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
				If aMatBD6[nI,4] <> cTipGui
					//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
					//Ё Total Tipo Guia														  Ё
					//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
					PlsImpTTG(cTipGui,nI)
					//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
					//Ё Tipo Guia														   		  Ё
					//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
					PlsImpTpG(3,nI)
				EndIf
				//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
				//Ё Usuario																   Ё
				//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
				aProcs := PlsImpUsr(.T.,cTipGui,nI)
				if Len(aProcs) == 0
					PlsTotali("-1",nil,aMatBD6[nI,4],nil,aProcs)
				endif
				//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
				//Ё Lot e Ser																   Ё
				//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
				PlsImpLot(aProcs,nI)
				PlsImpSer(aProcs,nI)
				//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
				//Ё Mudou o servico da guia	                                               Ё
				//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
			Elseif nI <= Len(aMatBD6)
				PlsImpSer(aProcs,nI)
			Else
				If nI > Len(aMatBD6)
					nI--
				EndIf
				//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
				//Ё Totais																   Ё
				//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
				PlsTotali("3",nil,cTipGui,aCurrent,aProcs)//totalizo a guia anterior
				//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
				//Ё Taxa																	   Ё
				//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
				PlsImpTax(cChaveBD6,aProcs)
				//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
				//Ё Total Tipo Guia														   Ё
				//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
				PlsImpTTG(cTipGui,nI)
				//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
				//Ё Total Empresa															   Ё
				//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
				PlsImpTEm()
				nI++
			Endif
			//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
			//Ё Nao entra na primeira rotina do for									   Ё
			//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
			lFirst := .F.
			
			If nI <= Len(aMatBD6)
				nI--
			Else
				//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
				//Ё Total de Pago,Glosado,Reconsiderado										 Ё
				//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
				PlsImpTFP(cMsgOrd)
			EndIf
		Endif
	Next
Next	
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//| Resumo 																	 |
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды 
PlsImpRes()
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//| Imprime Relatorio de Contestacao Itens Glosado e Reconsiderado			 |
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды 
If lImpCon
   PlsImpCot()
EndIf	
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Libera impressao                                                         Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
If !lautoSt .AND. aReturn[5] == 1
    Set Printer To
	OurSpool(nrel)
Endif
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Fim do Relat╒rio                                                         Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
Return
/*/
ээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээ
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
╠╠здддддддддддбдддддддддддбдддддддбддддддддддддддддддддддбддддддбдддддддддд©╠╠
╠╠ЁPrograma   Ё PlsImpCot Ё Autor Ё Alexander			 Ё Data Ё 07.12.05 Ё╠╠
╠╠цдддддддддддедддддддддддадддддддаддддддддддддддддддддддаддддддадддддддддд╢╠╠
╠╠ЁDescricao  Ё Imprime relatorio de contestacao						   Ё╠╠
╠╠юдддддддддддадддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды╠╠
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
/*/                 
Function PlsImpCot()
//LOCAL cCodGlo
LOCAL nI 	   := 1  
LOCAL nLi 	   := 0                                                                  
//LOCAL nTotCot  := 0
LOCAL nTotGCot := 0                  
LOCAL cHistorico

If Len(aMatCot) > 0
	//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	//Ё Imprime o Cabecalho da Nota												 Ё
	//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
	nLi := CabContes()
	//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	//Ё For para impressao dos valores por motivo de glosa						 Ё
	//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
	For nI := 1 To Len(aMatCot)    
	    cHistorico 	:= AllTrim(aMatCot[nI,1]) + ' - ' +Left(aMatCot[nI,2],65)
   	    nTotGCot 	:= nTotGCot + aMatCot[nI,3]   
	    @ nli++, 0 PSAY cHistorico + Space(2) + Iif(Empty(aMatCot[nI,3]),"",TransForm(aMatCot[nI,3],pMoeda1))
	    
		If !Empty(aMatCot[nI,4]) .And. nI <> Len(aMatCot)
		    @ nli++, 0 PSAY '-----------------------------'
	    EndIf                   
	    
	    If nli > nLinPag
		   nLi := CabContes()
	    EndIf
	Next  
	
	@ nli++, 0 PSAY Replicate('-',nLimite)
	@ nli++, 0 PSAY STR0016 + TransForm(nTotGCot,pMoeda2) //"Total da ContestaГЦo: "
	@ nli++, 0 PSAY Replicate('-',nLimite)
	@ nli++, 0 PSAY Space(50)+STR0017 //" O B S E R V A г у E S"
	@ nli++, 0 PSAY Replicate('-',nLimite)
EndIf	     
Return
/*/
ээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээ
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
╠╠здддддддддддбдддддддддддбдддддддбддддддддддддддддддддддбддддддбдддддддддд©╠╠
╠╠ЁPrograma   Ё CabContes Ё Autor Ё Alexander			 Ё Data Ё 07.12.05 Ё╠╠
╠╠цдддддддддддедддддддддддадддддддаддддддддддддддддддддддаддддддадддддддддд╢╠╠
╠╠ЁDescricao  Ё Cabecalho do relatorio									   Ё╠╠
╠╠юдддддддддддадддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды╠╠
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
/*/

Static Function CabContes()

nli := Cabec(STR0018,Space(114)+STR0019+posicione("BRJ",4,xFilial("BRJ")+cLoteImp+cAno+cMes,"BRJ_FCBPLS"),"",cNomeProg,cTamanho,nCaracter) //"Nota de Debito e Credito"###"N.:"
		//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
		//Ё Posiciona na Operadora credora											 Ё
		//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
		BA0->( DbSetOrder(1) )
BA0->( MsSeek( xFilial("BA0")+PlsIntPad() ) )
		nli++
		@ nli++, 0 PSAY STR0020 + 	objCENFUNLGP:verCamNPR("BA0_CODIDE",BA0->BA0_CODIDE)+;
									objCENFUNLGP:verCamNPR("BA0_CODINT",BA0->BA0_CODINT) + "-" + ;
									objCENFUNLGP:verCamNPR("BA0_NOMINT",AllTrim(BA0->BA0_NOMINT)) //"Credor...: "
		@ nli++, 0 PSAY STR0021 + 	objCENFUNLGP:verCamNPR("BA0_END",BA0->BA0_END) //"Endereco.: "
		@ nli++, 0 PSAY STR0022 + 	objCENFUNLGP:verCamNPR("BA0_BAIRRO",BA0->BA0_BAIRRO) + Space(2) + STR0023 + ;
									objCENFUNLGP:verCamNPR("BA0_CIDADE",BA0->BA0_CIDADE) + Space(2) + STR0024 + ;
									objCENFUNLGP:verCamNPR("BA0_EST",BA0->BA0_EST) + Space(2) + STR0025 + ;
									objCENFUNLGP:verCamNPR("BA0_CEP",BA0->BA0_CEP) //"Bairro...: "###"Cidade.: "###"Estado.: "###"Cep.: "
		@ nli++, 0 PSAY STR0026 + 	objCENFUNLGP:verCamNPR("BA0_TELEF1",BA0->BA0_TELEF1) + Space(2) + STR0027 + ;
									objCENFUNLGP:verCamNPR("BA0_FAX1",BA0->BA0_FAX1)  //"Telefone.: "###"Fax.: "
		@ nli++, 0 PSAY STR0028 + 	objCENFUNLGP:verCamNPR("BA0_CGC",BA0->BA0_CGC) //"CNPJ.....: "
		
		@ nli++, 0 PSAY Replicate('-',nLimite)
		//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Posiciona na Operadora devedora													 Ё
		//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
		BA0->(DbSetOrder(1))
BA0->( MsSeek( xFilial("BA0")+BAU->BAU_CODOPE ) )
		
		@ nli++, 0 PSAY STR0029 + 	objCENFUNLGP:verCamNPR("BA0_CODIDE",BA0->BA0_CODIDE)+;
									objCENFUNLGP:verCamNPR("BA0_CODINT",BA0->BA0_CODINT) + "-" + ;
									objCENFUNLGP:verCamNPR("BA0_NOMINT",AllTrim(BA0->BA0_NOMINT)) //"Devedor..: "
		@ nli++, 0 PSAY STR0021 + 	objCENFUNLGP:verCamNPR("BA0_END",BA0->BA0_END) //"Endereco.: "
		@ nli++, 0 PSAY STR0022 + 	objCENFUNLGP:verCamNPR("BA0_BAIRRO",BA0->BA0_BAIRRO) + Space(2) + STR0023 + ;
									objCENFUNLGP:verCamNPR("BA0_CIDADE",BA0->BA0_CIDADE) + Space(2) + STR0024 + ;
									objCENFUNLGP:verCamNPR("BA0_EST",BA0->BA0_EST) + Space(2) + STR0025 + ;
									objCENFUNLGP:verCamNPR("BA0_CEP",BA0->BA0_CEP) //"Bairro...: "###"Cidade.: "###"Estado.: "###"Cep.: "
		@ nli++, 0 PSAY STR0026 + 	objCENFUNLGP:verCamNPR("BA0_TELEF1",BA0->BA0_TELEF1) + Space(2) + STR0027 + ;
									objCENFUNLGP:verCamNPR("BA0_FAX1",BA0->BA0_FAX1) //"Telefone.: "###"Fax.: "
		@ nli++, 0 PSAY STR0028 + 	objCENFUNLGP:verCamNPR("BA0_CGC",BA0->BA0_CGC) //"CNPJ.....: "

		@ nli++, 0 PSAY Replicate('-',nLimite)
		
		@ nli++, 0 PSAY STR0030 + Space(10) + STR0031 //"Emissao"###"Vencimento"
		SE1->(DbSetorder(1))
		If SE1->(MsSeek(xFilial("SE1")+BRJ->BRJ_FCBPLS))
			@ nli++, 0 PSAY objCENFUNLGP:verCamNPR("E1_EMISSAO",DtoC(SE1->E1_EMISSAO)) + Space(9) + ;
							objCENFUNLGP:verCamNPR("E1_VENCREA",DtoC(SE1->E1_VENCREA))
		Else 
			@ nli++, 0 PSAY DtoC(dDataBase) + Space(9) + DtoC(dDataBase+15)
		Endif
		@ nli++, 0 PSAY Replicate("-",nLimite)

		@ nli++, 0 PSAY Space(50)+STR0032 //"Dados da Fatura Original"

		@ nli++, 0 PSAY Replicate("-",nLimite)

		@ nli++, 0 PSAY	STR0083 + Space(10) + STR0030 + Space(10) + STR0033   //"Numero"###"Emissao"###"Valor"
		@ nli++, 0 PSAY objCENFUNLGP:verCamNPR("BRJ_NUMFAT",alltrim(posicione("BRJ",4,xFilial("BRJ")+cLoteImp+cAno+cMes,"BRJ_NUMFAT"))) + Space(5) +;
						objCENFUNLGP:verCamNPR("BRJ_DTEMIS",DtoC( posicione("BRJ",4,xFilial("BRJ")+cLoteImp+cAno+cMes,"BRJ_DTEMIS"))) + Space(5) +;
						objCENFUNLGP:verCamNPR("BRJ_VALOR",TransForm(BRJ->BRJ_VALOR,pMoeda1)) 

		@ nli++, 0  PSAY Replicate('-',nLimite)
		@ nli++, 0  PSAY STR0034 + Space(47) + STR0033   //"Historico de Criticas Agrupadas"###"Valor"
		@ nli++, 0  PSAY Replicate('-',nLimite)
		nLi++				
Return(nli)
/*/
ээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээ
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
╠╠здддддддддддбдддддддддддбдддддддбддддддддддддддддддддддбддддддбдддддддддд©╠╠
╠╠ЁPrograma   Ё R674RDA   Ё Autor Ё Daher			     Ё Data Ё 28.07.05 Ё╠╠
╠╠цдддддддддддедддддддддддадддддддаддддддддддддддддддддддаддддддадддддддддд╢╠╠
╠╠ЁDescricao  Ё Imprime dados da RDA                                       Ё╠╠
╠╠юдддддддддддадддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды╠╠
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
/*/
Static Function R674RDA()
LOCAL cLinCab
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Imprime dados da RDA                                                     Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
nli := 999
If lautoSt
	cLinha := STR0038 + Iif(cSituac=='1','Ativo',Iif(cSituac=='2','Cancelado','Bloqueado'))
else
	cLinha:= STR0035 + objCENFUNLGP:verCamNPR("BAU_CODIGO",BAU->BAU_CODIGO) + "-" +;
		 objCENFUNLGP:verCamNPR("BAU_NOME",alltrim(BAU->BAU_NOME)) + ;		//"R.D.A.: "
         STR0036 + objCENFUNLGP:verCamNPR("BAG_DESCRI",alltrim(posicione("BAG",1,xFilial("BAG")+BAU->BAU_TIPPRE,"BAG_DESCRI"))) + ; 				//"   Classe: "
         STR0037 + objCENFUNLGP:verCamNPR("BRJ_NUMFAT",alltrim(posicione("BRJ",4,xFilial("BRJ")+cLoteImp+cAno+cMes,"BRJ_NUMFAT"))) + Space(5) + ;	//"   Fatura: "
         STR0038 + Iif(cSituac=='1','Ativo',Iif(cSituac=='2','Cancelado','Bloqueado') ) 						//" SituaГЦo: "
endIf
R674Linha(cLinha,1,0)
R674Linha(STR0039+space(14)+STR0040,1,0)	//"Sol. Origem - Matricula"###"Nome"
cLinCab := STR0041							//"Nro.Peg   "
If lImpGui 
	cLinCab += STR0042						//"Nro.Guia  "
EndIf
If lImpPre
	cLinCab += STR0043						//"Nro.Impresso"
EndIf
R674Linha(cLinCab,1,0)
R674Linha(STR0044,1,0)						//"                  Cod.Proced.     Descricao"
R674Linha(space(19)+"Qtd Part. Ref.TDE         Dat.Proc.  Vlr.Pagto  Vlr.Apres. Vlr.Dif.   Vlr.Tx.Pgt. Vlr.Tx.Apr Vlr.Tx.Dif" ,1,0) 			
Return
/*/
ээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээ
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
╠╠здддддддддддбдддддддддддбдддддддбддддддддддддддддддддддбддддддбдддддддддд©╠╠
╠╠ЁPrograma   Ё R674Linha Ё Autor Ё Daher			     Ё Data Ё 03.02.05 Ё╠╠
╠╠цдддддддддддедддддддддддадддддддаддддддддддддддддддддддаддддддадддддддддд╢╠╠
╠╠ЁDescricao  Ё Imprime linha de detalhe                                   Ё╠╠
╠╠юдддддддддддадддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды╠╠
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
/*/
Static Function R674Linha(cLinha,nAntes,nApos,lImprime,lResumo,lImpCabec)
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Declara variaveis                                                        Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
LOCAL i
LOCAL nLiRDA := nLi                           
LOCAL cLinCab
DEFAULT lImprime := .T.
DEFAULT lResumo  := .F.     
DEFAULT lImpCabec:= .T.

if !lImprime
     return
endif                              
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Salta linhas antes                                                       Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
If lResumo
	nli := 999
Endif         

For i := 1 to nAntes
    nli++
Next    
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Imprime cabecalho                                                        Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
If  nli > nLinPag
    nli := Cabec(cTitulo,cCabec1,cCabec2,cNomeProg,cTamanho,nCaracter)
    nli++               
    
	//Acrescenta "R.D.A - CLASSE" a cada nova pagina.
	If nLiRDA <> 999 .and. lImpCabec
		@ nli++, 0 PSAY STR0035 + 	objCENFUNLGP:verCamNPR("BAU_CODIGO",BAU->BAU_CODIGO) + "-" +;
									objCENFUNLGP:verCamNPR("BAU_NOME",alltrim(BAU->BAU_NOME)) +; 	//"R.D.A.: "
		STR0028 + objCENFUNLGP:verCamNPR("BAG_DESCRI",alltrim(posicione("BAG",1,xFilial("BAG")+BAU->BAU_TIPPRE,"BAG_DESCRI"))) + ; 		//"   Classe: "
		STR0029 + objCENFUNLGP:verCamNPR("BRJ_NUMFAT",alltrim(posicione("BRJ",4,xFilial("BRJ")+cLoteImp+cAno+cMes,"BRJ_NUMFAT"))) 		//"   Fatura: "
		@ nli++, 0 PSAY STR0039+space(14)+STR0040	//"Sol. Origem - Matricula"###"Nome"
		cLinCab := STR0041							//"Nro.Peg   "
		If lImpGui
			cLinCab += STR0042						//"Nro.Guia  "
		EndIf
		If lImpPre
			cLinCab += STR0043						//"Nro.Impresso"
		EndIf
		@ nli++, 0 PSAY cLinCab
			
		@ nli++, 0 PSAY STR0044		//"                  Cod.Proced.     Descricao"
		@ nli++, 0 PSAY space(23)+"Qtd Part. Ref.TDE     Dat.Proc.  Vlr.Pagto  Vlr.Apres. Vlr.Dif.   Vlr.Tx.Pgt. Vlr.Tx.Apr Vlr.Tx.Dif"
		@ nli++, 0 PSAY Replicate('-',nLimite)
	EndIf
	
Endif    
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Imprime linha de detalhe                                                 Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
@ nLi, 0 pSay cLinha
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Salta linhas apos                                                        Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
For i := 1 to nApos
    nli++
Next    
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Fim da funcao                                                            Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
Return
/*
эээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээ
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
╠╠иммммммммммямммммммммммммммкммммммяммммммммммммммммммкммммммяммммммммммм╩╠╠
╠╠╨Programa  ЁRetMesAno      ╨Autor ЁPaulo Carnelossi  ╨ Data Ё 09/01/04  ╨╠╠
╠╠лммммммммммьмммммммммммммммйммммммоммммммммммммммммммйммммммоммммммммммм╧╠╠
╠╠╨Desc.     ЁRetorna Mes/Ano                                             ╨╠╠
╠╠лммммммммммьмммммммммммммммммммммммммммммммммммммммммммммммммммммммммммм╧╠╠
╠╠╨Uso       Ё AP                                                         ╨╠╠
╠╠хммммммммммомммммммммммммммммммммммммммммммммммммммммммммммммммммммммммм╪╠╠
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
ъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъ
*/
Static Function	RetMesAno(cAnoMes)
Static aMeses := {"Jan","Fev","Mar","Abr","Mai","Jun",;
					"Jul", "Ago", "Set", "Out", "Nov", "Dez"}
Local cString := ""					

If Val(Right(cAnoMes,2)) > 0 .And. Val(Right(cAnoMes,2)) <= 12
    cString := aMeses[Val(Right(cAnoMes,2))]+"/"+Left(cAnoMes,4)
Else
    cString := Right(cAnoMes,2)+"/"+Left(cAnoMes,4)
EndIf

Return(cString) 
/*
эээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээ
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
╠╠иммммммммммямммммммммммммммкммммммяммммммммммммммммммкммммммяммммммммммм╩╠╠
╠╠╨Programa  ЁPlsImpTax      ╨Autor ЁDaher             ╨ Data Ё 22/07/05  ╨╠╠
╠╠лммммммммммьмммммммммммммммйммммммоммммммммммммммммммйммммммоммммммммммм╧╠╠
╠╠╨Desc.     Ё				                                              ╨╠╠
╠╠лммммммммммьмммммммммммммммммммммммммммммммммммммммммммммммммммммммммммм╧╠╠
╠╠╨Uso       Ё AP                                                         ╨╠╠
╠╠хммммммммммомммммммммммммммммммммммммммммммммммммммммммммммммммммммммммм╪╠╠
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
ъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъ
*/
Static Function PlsImpTax(cChave,aProcs)
LOCAL aMatBDX := {}
LOCAL nI	
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё If																		 Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
If Len(aProcs) > 0	
	R674Linha(space(42)+STR0045+TransForm(aCurrent[2][1],pMoeda1)					+ space(1) +; //valor pagamento                   // // // //"Total Guia: "
		  					  	 TransForm(aCurrent[2][2],pMoeda1)					+ space(1) +; //valor apresentado                                    
		                      	 TransForm(aCurrent[2][1]-aCurrent[2][2],pMoeda1)	+ space(1) +; //valor diferencas
		                      	 TransForm(aCurrent[2][7],pMoeda1)					+ space(1) +; //valor tx pagto
		                      	 TransForm(aCurrent[2][8],pMoeda1)					+ space(1) +; //valor tx aprese
		                      	 TransForm(aCurrent[2][7]-aCurrent[2][8],pMoeda1),1,0)			  //valor Tx diferencas       
	//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	//Ё Seek																	 Ё
	//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
	BDX->( DbSetOrder(1) )//BDX_FILIAL+BDX_CODOPE+BDX_CODLDP+BDX_CODPEG+BDX_NUMERO+BDX_ORIMOV+BDX_CODPAD+BDX_CODPRO+BDX_SEQUEN+BDX_CODGLO	                      			
	If BDX->(MsSeek(cChave))      
		aCriticas[1][1] += 1
		R674Linha(Replicate('-',nLimite),1,0,lImpCrit)
		R674Linha(STR0046,1,0,lImpCrit) //"Criticas"
		R674Linha(Replicate('-',nLimite),1,0,lImpCrit)
		//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
		//Ё While																	 Ё
		//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
		While !BDX->( Eof() ) .And. cChave == BDX->(BDX_FILIAL+BDX_CODOPE+BDX_CODLDP+BDX_CODPEG+BDX_NUMERO) 
			cCodPro := BDX->BDX_CODPRO 
			//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
			//Ё Procedimento x criticas													 Ё
			//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
			If Ascan( aProcs,{ |x| x[1] == BDX->(BDX_CODPAD+BDX_CODPRO) } ) > 0 .And. BDX->BDX_TIPREG == "1"
				//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
				//Ё Se nao imprime reconsiderados 100%										 Ё
				//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
				If !( !lImpRec .And. BDX->BDX_PERGLO == 100 .And. BDX->BDX_ACAO == '2' ) 
				    If ( nPos := Ascan( aMatBDX,{ |x| x[1] == BDX->BDX_CODGLO } ) ) == 0			
					   AaDd(aMatBDX,{BDX->BDX_CODGLO,BDX->(BDX_CODPAD+BDX_CODPRO),Transform(AllTrim( BDX->(BDX_CODPAD+BDX_CODPRO) ),"@R !!-!!.!!.!!!-!"),AllTrim(BDX->BDX_DESGLO),AllTrim(BDX->BDX_INFGLO) } )
					   If Ascan( aMatBDX,{ |x| x[2] == BDX->(BDX_CODPAD+BDX_CODPRO) } ) == 0			
					   	  aCriticas[1][2] += 1
					   EndIf  
				    Else                 
				      If !Empty(aMatBDX[nPos,3])
						  aMatBDX[nPos,3] := aMatBDX[nPos,3]+", "+Transform(AllTrim( BDX->(BDX_CODPAD+BDX_CODPRO) ),"@R !!-!!.!!.!!!-!")
					      aCriticas[1][2] += 1
					  EndIf	  
				    EndIf	
				EndIf    
			Endif
			//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
			//Ё DbSkip																	 Ё
			//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
			BDX->( DbSkip() )
		EndDo	
		//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
		//Ё Verifica se existe alguma critica informada no parametro				 Ё
		//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
		aMatBDXOd := {}
		If (nPos := Ascan( aMatBDX,{ |x| x[1] $ cCritica } ) ) > 0			
			For nI := 1 To Len(aMatBDX)              
			    If aMatBDX[nI,1] $ cCritica
			       AaDd( aMatBDXOd , { aMatBDX[nI,1],aMatBDX[nI,2],aMatBDX[nI,3],aMatBDX[nI,4],aMatBDX[nI,5] } )
			    EndIf    
			Next                        
			//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
			//Ё Se existir registro atualiza											 Ё
			//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
			If Len(aMatBDXOd) > 0
			   aMatBDX := {}
			   aMatBDX := aClone(aMatBDXOd)
			EndIf	
		EndIf	
		//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
		//Ё For	x Imprime															 Ё
		//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
		For nI := 1 To Len(aMatBDX)              
		    If !Empty(aMatBDX[nI,3])
		        R674Linha( "("+aMatBDX[nI,3]+")",1,0,lImpCrit )
		    EndIf    
			R674Linha( aMatBDX[nI,4]+Space(1)+aMatBDX[nI,5],1,0,lImpCrit )  
		Next
		//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
		//Ё Imprime																	 Ё
		//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
		R674Linha(Replicate('-',nLimite),1,0,lImpCrit)	
	Endif 
Endif	
aCurrent[2] := __SIZEACURRGUI      
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Fim da Rotina															 Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
Return    
/*
эээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээ
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
╠╠иммммммммммямммммммммммммммкммммммяммммммммммммммммммкммммммяммммммммммм╩╠╠
╠╠╨Programa  ЁPlsImpEmp      ╨Autor ЁDaher             ╨ Data Ё 22/07/05  ╨╠╠
╠╠лммммммммммьмммммммммммммммйммммммоммммммммммммммммммйммммммоммммммммммм╧╠╠
╠╠╨Desc.     Ё				                                              ╨╠╠
╠╠лммммммммммьмммммммммммммммммммммммммммммммммммммммммммммммммммммммммммм╧╠╠
╠╠╨Uso       Ё AP                                                         ╨╠╠
╠╠хммммммммммомммммммммммммммммммммммммммммммммммммммммммммммммммммммммммм╪╠╠
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
ъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъ
*/
static Function PlsImpEmp(nI)
LOCAL  cGruEmp := ""
        
BA1->( DbSetOrder(2) )//BA1_FILIAL + BA1_CODINT + BA1_CODEMP + BA1_MATRIC + BA1_TIPREG + BA1_DIGITO
BA1->( MsSeek( xFilial("BA1")+aMatBD6[nI,17]+aMatBD6[nI,3]+aMatBD6[nI,7]+aMatBD6[nI,15]+aMatBD6[nI,21] ) )

cGruEmp := STR0047+BA1->(BA1_CODINT+"."+BA1_CODEMP) + space(3) + Posicione("BG9",1,xFilial("BG9")+BA1->(BA1_CODINT+BA1_CODEMP),"BG9_DESCRI")  //"Empresa: "
R674Linha(Replicate('-',nLimite),1,0)
R674Linha(cGruEmp,1,0)
R674Linha(Replicate('-',nLimite),1,0)
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Fim da Rotina															 Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
Return
/*
эээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээ
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
╠╠иммммммммммямммммммммммммммкммммммяммммммммммммммммммкммммммяммммммммммм╩╠╠
╠╠╨Programa  ЁPlsImpUsr      ╨Autor ЁDaher             ╨ Data Ё 22/07/05  ╨╠╠
╠╠лммммммммммьмммммммммммммммйммммммоммммммммммммммммммйммммммоммммммммммм╧╠╠
╠╠╨Desc.     Ё				                                              ╨╠╠
╠╠лммммммммммьмммммммммммммммммммммммммммммммммммммммммммммммммммммммммммм╧╠╠
╠╠╨Uso       Ё AP                                                         ╨╠╠
╠╠хммммммммммомммммммммммммммммммммммммммммммммммммммммммммммммммммммммммм╪╠╠
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
ъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъ
*/
static Function PlsImpUsr(lPos,cTipGui,nI)	    
LOCAL cNomUsr := ""                                            
LOCAL aRet    := {}
LOCAL nOrdBD6 := BD6->(IndexOrd())
LOCAL nRecBD6 := BD6->(Recno())
DEFAULT lPos := .F.   
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Otimizacao    															 Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды                              
BD6->( DbSetOrder(1) )//BD6_FILIAL + BD6_CODOPE + BD6_CODLDP + BD6_CODPEG + BD6_NUMERO + BD6_ORIMOV + BD6_SEQUEN + BD6_CODPAD + BD6_CODPRO
If BD6->( MsSeek( xFilial("BD6")+aMatBD6[nI,17]+aMatBD6[nI,18]+aMatBD6[nI,5]+aMatBD6[nI,6]+aMatBD6[nI,10] ) )

	While !BD6->( Eof() ) .And. BD6->(BD6_FILIAL+BD6_CODOPE+BD6_CODLDP+BD6_CODPEG+BD6_NUMERO+BD6_ORIMOV) == (aMatBD6[nI,1]+aMatBD6[nI,17]+aMatBD6[nI,18]+aMatBD6[nI,5]+aMatBD6[nI,6]+aMatBD6[nI,10])
	    AaDd(aRet,{ BD6->(BD6_CODPAD+BD6_CODPRO) } )
		BD6->(DbSkip())
	EndDo
	
EndIf

If Len(aRet) > 0	  
    If lMatAnt .And. !Empty(aMatBD6[nI,20])
	   cNomUsr := aMatBD6[nI,23]+" - "+Transform(aMatBD6[nI,20],"@R !!!!.!!!!.!!!!!!.!!-!") + Space(2) + Subs(aMatBD6[nI,22],1,42)
	Else
	   cNomUsr := aMatBD6[nI,23]+" - "+Transform(aMatBD6[nI,17]+aMatBD6[nI,3]+aMatBD6[nI,7]+aMatBD6[nI,15]+aMatBD6[nI,21],"@R !!!!.!!!!.!!!!!!.!!-!") + Space(2) + Subs(aMatBD6[nI,22],1,42)
	EndIf   
	R674Linha(cNomUsr,2,0)                	      
EndIf                      

BD6->(DbGoTo(nRecBD6))
BD6->(DbSetOrder(nOrdBD6))

Return aRet                   
/*
эээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээ
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
╠╠иммммммммммямммммммммммммммкммммммяммммммммммммммммммкммммммяммммммммммм╩╠╠
╠╠╨Programa  ЁPlsImpSer      ╨Autor ЁDaher             ╨ Data Ё 22/07/05  ╨╠╠
╠╠лммммммммммьмммммммммммммммйммммммоммммммммммммммммммйммммммоммммммммммм╧╠╠
╠╠╨Desc.     Ё				                                              ╨╠╠
╠╠лммммммммммьмммммммммммммммммммммммммммммммммммммммммммммммммммммммммммм╧╠╠
╠╠╨Uso       Ё AP                                                         ╨╠╠
╠╠хммммммммммомммммммммммммммммммммммммммммммммммммммммммммммммммммммммммм╪╠╠
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
ъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъ
*/
static Function PlsImpSer(aProcs,nI)
LOCAL cServic := ""
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Posiciona BR8-Tabela Padrao                                              Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
If  BR8->(BR8_CODPAD+BR8_CODPSA) <> (aMatBD6[nI,13]+aMatBD6[nI,14])
	BR8->( DbSetOrder(1) )
	BR8->( MsSeek( xFilial("BR8")+aMatBD6[nI,13]+aMatBD6[nI,14] ) )
Endif
If Len(aProcs) > 0 .And. Ascan(aProcs,{|x| x[1] == aMatBD6[nI,13]+aMatBD6[nI,14] } ) > 0          
	cServic := Space(18)+TransForm( aMatBD6[nI,13]+aMatBD6[nI,14] ,"@R !! !!.!!.!!!-!") + "  " + SubStr(BR8->BR8_DESCRI,1,100)
	R674Linha(cServic,1,0)
endif

Return             
/*
эээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээ
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
╠╠иммммммммммямммммммммммммммкммммммяммммммммммммммммммкммммммяммммммммммм╩╠╠
╠╠╨Programa  ЁPlsTotali      ╨Autor ЁDaher             ╨ Data Ё 22/07/05  ╨╠╠
╠╠лммммммммммьмммммммммммммммйммммммоммммммммммммммммммйммммммоммммммммммм╧╠╠
╠╠╨Desc.     Ё				                                              ╨╠╠
╠╠лммммммммммьмммммммммммммммммммммммммммммммммммммммммммммммммммммммммммм╧╠╠
╠╠╨Uso       Ё AP                                                         ╨╠╠
╠╠хммммммммммомммммммммммммммммммммммммммммммммммммммммммммммммммммммммммм╪╠╠
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
ъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъ
*/
static Function PlsTotali(cTipo,aDados,cTipGui,aCurrent,aProcs)
      
LOCAL nFor                           
DEFAULT aProcs	:= {}

If     cTipGui  == "01"
	nFor 	 := 5
Elseif cTipGui  == "02"
	nFor 	 := 6
Elseif cTipGui  $ "03,05"
	nFor 	 := 7
Endif  
	  
If cTipo == "-1"
		aVet[nFor][1] -= 1          // total notas
ElseIf cTipo == "1"                        
		aVet[nFor][1] += 1          // total notas
Elseif cTipo == "2" .and. Len(aProcs) > 0
		aVet[nFor][8][1][1]	+= aDados[1][1]	     	 // total real Referencia
		aVet[nFor][8][1][2]	+= aDados[1][2]			 // total real pago
		aVet[nFor][8][1][3]	+= aDados[1][3]			 // total real apresentado
		aVet[nFor][8][1][4]	+= aDados[1][4]			 // total Tx Pago
		aVet[nFor][8][1][5]	+= aDados[1][5]			 // total Tx Apresentado
							
		aVet[nFor][8][2][1]	+= aDados[2][1]			 // total ch Referencia
		aVet[nFor][8][2][2]	+= aDados[2][2]			 // total ch pago
		aVet[nFor][8][2][3]	+= aDados[2][3]			 // total ch Apresentado
		aVet[nFor][8][2][4]	+= aDados[2][4]			 // total ch tx Pago
		aVet[nFor][8][2][5]	+= aDados[2][5]			 // total ch tx Apresentado
			
		aVet[nFor][8][3][1]	+= aDados[3][1]		     // total m2 Referencia
		aVet[nFor][8][3][2] 	+= aDados[3][2]			 // total m2 pago
		aVet[nFor][8][3][3] 	+= aDados[3][3]			 // total m2 Apresentado
		aVet[nFor][8][3][4]	+= aDados[3][4]		     // total m2 Tx Pago
		aVet[nFor][8][3][5]	+= aDados[3][5]			 // total m2 Tx Apresenado 
		
		aVet[nFor][8][4][2] 	+= aDados[4][2]			 // total procedimento pago
		aVet[nFor][8][4][3] 	+= aDados[4][3]		     // total procedimento Apresentado
		aVet[nFor][8][4][4]	+= aDados[4][4]		     // total procedimento Tx Pago
		aVet[nFor][8][4][5]	+= aDados[4][5]			 // total procedimento tx Apresentado
		                               
		aVet[nFor][8][5][2] 	+= aDados[5][2]			 // total material pago
		aVet[nFor][8][5][3] 	+= aDados[5][3]			 // total material Apresentado
		aVet[nFor][8][5][4]	+= aDados[5][4]			 // total material Tx Pago                 
		aVet[nFor][8][5][5]	+= aDados[5][5]			 // total material Tx Apresentado 
		                               
		aVet[nFor][8][6][2] 	+= aDados[6][2]			 // total medicamento pago
		aVet[nFor][8][6][3] 	+= aDados[6][3]			 // total medicamento Apresentado
		aVet[nFor][8][6][4]	+= aDados[6][4]			 // total medicamento Tx Pago                 
		aVet[nFor][8][6][5]	+= aDados[6][5]			 // total medicamento Tx Apresentado 
		
		aVet[nFor][8][7][2] 	+= aDados[7][2]			 // total taxas pago
		aVet[nFor][8][7][3] 	+= aDados[7][3]			 // total taxas Apresentado
		aVet[nFor][8][7][4]	+= aDados[7][4]			 // total taxas Tx Pago                 
		aVet[nFor][8][7][5]	+= aDados[7][5]			 // total taxas Tx Apresentado 
		
		aVet[nFor][8][8][2] 	+= aDados[8][2]			 // total diarias pago
		aVet[nFor][8][8][3] 	+= aDados[8][3]			 // total diarias Apresentado
		aVet[nFor][8][8][4]	+= aDados[8][4]			 // total diarias Tx Pago                 
		aVet[nFor][8][8][5]	+= aDados[8][5]			 // total diarias Tx Apresentado 
		
		aVet[nFor][8][9][2] 	+= aDados[9][2]			 // total ortese/protese pago
		aVet[nFor][8][9][3] 	+= aDados[9][3]			 // total ortese/protese Apresentado
		aVet[nFor][8][9][4]	+= aDados[9][4]			 // total ortese/protese Tx Pago                 
		aVet[nFor][8][9][5]	+= aDados[9][5]			 // total ortese/protese Tx Apresentado 
                                  
ElseIf cTipo == "3" .and. len(aProcs) > 0
		aVet[1] += aCurrent[2][1] // total Pago
		aVet[2] += aCurrent[2][2] // total Apresentado
		aVet[3] += aCurrent[2][7] // total Tx Pago
		aVet[4] += aCurrent[2][8] // total Tx Apresentado           
		
		aVet[nFor][2] += aCurrent[2][5] // total itens
	    aVet[nFor][3] += aCurrent[2][6] // total subitens         
	    
	    aVet[nFor][4] += aCurrent[2][1] // total Pago
		aVet[nFor][5] += aCurrent[2][2] // total Apresentado
		aVet[nFor][6] += aCurrent[2][7] // total Tx Pago 
		aVet[nFor][7] += aCurrent[2][8] // total Tx Apresentado
Endif                     

Return                          
/*
эээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээ
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
╠╠иммммммммммямммммммммммммммкммммммяммммммммммммммммммкммммммяммммммммммм╩╠╠
╠╠╨Programa  ЁPlsImpLot      ╨Autor ЁDaher             ╨ Data Ё 22/07/05  ╨╠╠
╠╠лммммммммммьмммммммммммммммйммммммоммммммммммммммммммйммммммоммммммммммм╧╠╠
╠╠╨Desc.     Ё				                                              ╨╠╠
╠╠лммммммммммьмммммммммммммммммммммммммммммммммммммммммммммммммммммммммммм╧╠╠
╠╠╨Uso       Ё AP                                                         ╨╠╠
╠╠хммммммммммомммммммммммммммммммммммммммммммммммммммммммммммммммммммммммм╪╠╠
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
ъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъ
*/
static Function PlsImpLot(aProcs,nI)
LOCAL cLote := aMatBD6[nI,5]+Space(2)
If lImpGui
   cLote += aMatBD6[nI,6]+Space(2)
EndIf
If lImpPre   
   cLote += aMatBD6[nI,19]
EndIf   
If Len(aProcs) > 0
   R674Linha(cLote,1,0)
EndIf

Return         
/*
эээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээ
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
╠╠иммммммммммямммммммммммммммкммммммяммммммммммммммммммкммммммяммммммммммм╩╠╠
╠╠╨Programa  ЁPLSImpBD7      ╨Autor ЁDaher             ╨ Data Ё 22/07/05  ╨╠╠
╠╠лммммммммммьмммммммммммммммйммммммоммммммммммммммммммйммммммоммммммммммм╧╠╠
╠╠╨Desc.     Ё				                                              ╨╠╠
╠╠лммммммммммьмммммммммммммммммммммммммммммммммммммммммммммммммммммммммммм╧╠╠
╠╠╨Uso       Ё AP                                                         ╨╠╠
╠╠хммммммммммомммммммммммммммммммммммммммммммммммммммммммммммммммммммммммм╪╠╠
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
ъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъ
*/
Static Function PLSImpBD7(cChaveBD7,aCurrent,aProcs,nI)
LOCAL nFor
LOCAL cGrupo  := ""
LOCAL aMatGru := {}	      
LOCAL nValor  := 0
LOCAL nVlrRef := 0
LOCAL nTaxa   := 0
LOCAL nVlrMAN:= 0
LOCAL lFirst  := .T.
LOCAL nVlrAPR := 0
LOCAL nVlrBpr := 0
LOCAL cCompos := ""
LOCAL nVLTXPG := 0
LOCAL nVLTXAP := 0
LOCAL nVlrTaC := 0
LOCAL nVlrTaD := 0 
Local nVlrTotGl := 0
LOCAL aRet    := 	 {__SIZEPARAMGUI,; //r$
				      __SIZEPARAMGUI,; //ch
           		      __SIZEPARAMGUI,; //m2
           		      __SIZEPARAMGUI,; //proc
           		      __SIZEPARAMGUI,; //mat
           		      __SIZEPARAMGUI,; //med
           		      __SIZEPARAMGUI,; //taxa
           		      __SIZEPARAMGUI,; //diar
           		      __SIZEPARAMGUI,; //ortpro
           		      __SIZEPARAMGUI}  //taxa

While !BD7->( Eof() ) .And. ;
    cChaveBD7 == BD7->(BD7_FILIAL+BD7_CODOPE+BD7_CODLDP+BD7_CODPEG+BD7_NUMERO+BD7_ORIMOV+BD7_SEQUEN) .And.;
    Len(aProcs) > 0 .And. Ascan(aProcs,{|x| x[1] == aMatBD6[nI,13]+aMatBD6[nI,14] } ) > 0                                        

	nVlrRef  := BD7->BD7_REFTDE * aMatBD6[nI,16]	     	//Valor Referencia
	
	nVlrMAN := BD7->BD7_VLRMAN 								//Valor Pagamento
    nVLTXPG  := BD7->BD7_VLTXPG 					     	//Valor Tx Pagamento
                                                            
	nVlrAPR  := BD7->BD7_VALORI								//Valor apresentado
	nVLTXAP  :=	BD7->BD7_VTXPAP				   				//Valor da Taxa

    cCompos :=Space(21)+ ;
              Str(aMatBD6[nI,16],3)	            	+ Space(1) + ;
   	          BD7->BD7_CODUNM              			+ Space(1) + ;
       	      Str(nVlrRef,11,4)             		+ Space(1) + ;
        	  BD7->BD7_UNITDE              			+ Space(1) + ;
              dtoc(BD7->BD7_DATPRO)        			+ Space(1) + ;
        	  TransForm(nVlrMAN,pMoeda1)	        + Space(1) + ; //valor de pagamento 
    		  TransForm(nVlrAPR,pMoeda1)			+ Space(1) + ; //valor apresentado  
    		  TransForm(nVlrMAN - nVlrAPR,pMoeda1)	+ Space(1) + ; //valor Pago  - valor Apresentado
    		  TransForm(nVLTXPG,pMoeda1)			+ Space(1) + ; //valor taxa pagamento
    		  TransForm(nVLTXAP,pMoeda1)			+ Space(1) + ; //valor taxa  apresentada
    		  TransForm(nVLTXPG - nVLTXAP,pMoeda1)	 				//valor tx pago  - valor tx apresetado

	lItGl 	  := .F.
	nVlrTotGl += iif(((nVlrMAN - nVlrAPR) * -1) + (nVLTXPG - nVLTXAP) * -1 > 0,((nVlrMAN - nVlrAPR) * -1)+(nVLTXPG - nVLTXAP) * -1,0)
	
    If lImpCon    
       If ( round((nVlrMAN + nVLTXPG),2) - round((nVlrAPR + nVLTXAP),2) ) < 0
       
	       If BDX->( MsSeek(xFilial("BDX")+BD7->(BD7_CODOPE+BD7_CODLDP+BD7_CODPEG+BD7_NUMERO+BD7_ORIMOV+BD7_CODPAD+BD7_CODPRO+BD7_SEQUEN) ) )
			   //здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
			   //Ё Zera matriz															    Ё
			   //юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды	
			   aMatGru := {}	
			   cGrupo  := ""
			   nValor  := 0
			   //здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
			   //Ё While																	Ё
			   //юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды	
	           While !BDX->( Eof() ) .And. BDX->(BDX_CODOPE+BDX_CODLDP+BDX_CODPEG+BDX_NUMERO+BDX_ORIMOV+BDX_CODPAD+BDX_CODPRO+BDX_SEQUEN) == BD7->(BD7_CODOPE+BD7_CODLDP+BD7_CODPEG+BD7_NUMERO+BD7_ORIMOV+BD7_CODPAD+BD7_CODPRO+BD7_SEQUEN) .And.;
	                 BDX->BDX_TIPREG == "1" //Iif( Empty(BDX->BDX_ACAO) ,"1", BDX->BDX_ACAO ) == cBDXAcao .And. 
					 //здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
					 //Ё Valor e o grupo														  Ё
					 //юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды	
	                 nValor := Abs( (nVlrMAN + nVLTXPG) - (nVlrAPR + nVLTXAP) )
					 //здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
					 //Ё Matriz grupo															  Ё
					 //юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды	
			    	 AaDd( aMatGru , { BDX->BDX_CODGLO,BDX->BDX_DESGLO,0 } )
			    	 BDX->( DbSkip() )
			    EndDo
				//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
				//Ё Se por o ultimo coloca o valor										     Ё
				//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды	
				If !Empty(nValor)
					aMatGru[Len(aMatGru),3] := nValor
					nVlrTotGl := iif((nVlrTotGl - nValor)>0,nVlrTotGl - nValor,0) // Faco isso para somente colocar nas glosas a mais os valores que nao tem BDX
					lItGl := .T.
		    	EndIf    
				//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
				//Ё Ordena por codigo da critica											 Ё
				//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды	
			    aMatGru := aSort(aMatGru,,, { |x, y| x[1] < y[1] })
				//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
				//Ё Monta o grupo															 Ё
				//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды	
			    For nFor := 1 To Len(aMatGru)
		    	    cGrupo += aMatGru[nFor,1]
				Next
				//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
				//Ё Matriz de grupo de criticas												 Ё
				//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды	
			    For nFor := 1 To Len(aMatGru)                                                    
			         If ( nPos := Ascan( aMatCot,{|x| x[4] == cGrupo } ) ) == 0
			             If Empty(aMatGru[nFor,3])
					    	 AaDd( aMatCot , { aMatGru[nFor,1],aMatGru[nFor,2],aMatGru[nFor,3],"" } )
					     Else 
					    	 AaDd( aMatCot , { aMatGru[nFor,1],aMatGru[nFor,2],aMatGru[nFor,3],cGrupo } )
					     EndIf	 
				     Else                       
				         If !Empty(aMatGru[nFor,3])
					    	 aMatCot[nPos,3] += aMatGru[nFor,3]
					     EndIf	 
				     EndIf 	 
			    Next
		   EndIf		
	   EndIf   
		if nVlrTotGl > 0
			lItGl := .T.
			If ( nPos := Ascan( aMatCot,{|x| x[4] == "99" } ) ) == 0
				AaDd( aMatCot , { "99",STR0048+Space(30),nVlrTotGl,"99" } )		//"Glosa de valores conforme relatorio  "
			Else
				aMatCot[nPos,3] += nVlrTotGl
			Endif
			nVlrTotGl := 0
		Endif
	EndIf
	
	if lItGl .Or. !lImpRec
		
		R674Linha(cCompos,1,0)
		
		if lFirst
			aCurrent[2][5] += 1 //tot de itens da guia
			lFirst := .F.
		endif
		aCurrent[2][6] += 1 	//tot de subitens da guia
		
		//tot da guia valores diversos
		aCurrent[2][1] += nVlrMAN 	//Vlr Pago
		aCurrent[2][2] += nVlrAPR  	//Vlr Apresentado
		aCurrent[2][7] += nVLTXPG  	//Vlr Tx Pago
		aCurrent[2][8] += nVLTXAP  	//Vlr Tx Apresentado
		
		//Para totais por tipo de Guia
		aCurrent[3][1] += nVlrMAN 	//Vlr Pago
		aCurrent[3][2] += nVlrAPR  	//Vlr Apresentado
		aCurrent[3][3] += nVLTXPG  	//Vlr Tx Pago
		aCurrent[3][4] += nVLTXAP  	//Vlr Tx Apresentado
		
		//Para totais por (Pago,Glosado,Reconsiderado)
		aCurrent[4][1] += nVlrMAN 	//Vlr Pago
		aCurrent[4][2] += nVlrAPR  	//Vlr Apresentado
		aCurrent[4][3] += nVLTXPG  	//Vlr Tx Pago
		aCurrent[4][4] += nVLTXAP  	//Vlr Tx Apresentado
		
		//tot empresa := tot da guia valores diversos
		aCurrent[1][1] += nVlrMAN 	//Vlr Pago
		aCurrent[1][2] += nVlrAPR  	//Vlr Apresentado
		aCurrent[1][3] += nVLTXPG  	//Vlr Tx Pago
		aCurrent[1][4] += nVLTXAP  	//Vlr Tx Apresentado
		
		Do Case
			Case alltrim(BD7->BD7_UNITDE) == GetNewPar("MV_PLSCREA","R$")
				aRet[1][1]  += nVlrRef
				aRet[1][2]  += nVlrMAN
				aRet[1][3]  += nVlrAPR
				aRet[1][4]  += nVLTXPG
				aRet[1][5]  += nVLTXAP
			Case alltrim(BD7->BD7_UNITDE) == GetNewPar("MV_PLSCCH","CH")
				aRet[2][1]  += nVlrRef
				aRet[2][2]  += nVlrMAN
				aRet[2][3]  += nVlrAPR
				aRet[2][4]  += nVLTXPG
				aRet[2][5]  += nVLTXAP
			Case alltrim(BD7->BD7_UNITDE) == GetNewPar("MV_PLSCM2","M2")
				aRet[3][1]  += nVlrRef
				aRet[3][2]  += nVlrMAN
				aRet[3][3]  += nVlrAPR
				aRet[3][4]  += nVLTXPG
				aRet[3][5]  += nVLTXAP
		EndCase
		
		Do Case
			Case alltrim(BR8->BR8_TPPROC) == "0"
				aRet[4][2]  += nVlrMAN
				aRet[4][3]  += nVlrAPR
				aRet[4][4]  += nVLTXPG
				aRet[4][5]  += nVLTXAP
			Case alltrim(BR8->BR8_TPPROC) == "1"
				aRet[5][2]  += nVlrMAN
				aRet[5][3]  += nVlrAPR
				aRet[5][4]  += nVLTXPG
				aRet[5][5]  += nVLTXAP
			Case alltrim(BR8->BR8_TPPROC) == "2"
				aRet[6][2]  += nVlrMAN
				aRet[6][3]  += nVlrAPR
				aRet[6][4]  += nVLTXPG
				aRet[6][5]  += nVLTXAP
			Case alltrim(BR8->BR8_TPPROC) == "3"
				aRet[7][2]  += nVlrMAN
				aRet[7][3]  += nVlrAPR
				aRet[7][4]  += nVLTXPG
				aRet[7][5]  += nVLTXAP
			Case alltrim(BR8->BR8_TPPROC) == "4"
				aRet[8][2]  += nVlrMAN
				aRet[8][3]  += nVlrAPR
				aRet[8][4]  += nVLTXPG
				aRet[8][5]  += nVLTXAP
			Case alltrim(BR8->BR8_TPPROC) == "5"
				aRet[9][2]  += nVlrMAN
				aRet[9][3]  += nVlrAPR
				aRet[9][4]  += nVLTXPG
				aRet[9][5]  += nVLTXAP
		EndCase
		// taxas por tipo de guia
		aRet[10][2]  += nVLTXPG
		aRet[10][3]  += nVLTXAP
	Endif
	BD7->(DbSkip())
	
Enddo

Return aRet
	  
/*
эээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээ
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
╠╠иммммммммммямммммммммммммммкммммммяммммммммммммммммммкммммммяммммммммммм╩╠╠
╠╠╨Programa  ЁPlsImpRes      ╨Autor ЁDaher             ╨ Data Ё 22/07/05  ╨╠╠
╠╠лммммммммммьмммммммммммммммйммммммоммммммммммммммммммйммммммоммммммммммм╧╠╠
╠╠╨Desc.     Ё				                                              ╨╠╠
╠╠лммммммммммьмммммммммммммммммммммммммммммммммммммммммммммммммммммммммммм╧╠╠
╠╠╨Uso       Ё AP                                                         ╨╠╠
╠╠хммммммммммомммммммммммммммммммммммммммммммммммммммммммммммммммммммммммм╪╠╠
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
ъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъ
*/

static Function PlsImpRes()
LOCAL nFor 		:= 5
LOCAL nTotItens := 0
LOCAL nTotSubIt := 0
LOCAL nTotNotas	:= 0

R674Linha(space(20)+Replicate('-',nLimite),3,0,nil,.T.,.F.)      
R674Linha(space(20)+STR0049,1,0,nil,.F.,.F.)					//"Resumo Detalhado"
R674Linha(space(20)+Replicate('-',nLimite),1,0,nil,.F.,.F.)   

While nFor <= 7
	R674Linha(Replicate('-',nLimite),1,0,nil,.F.,.F.)
	If nFor == 5
		R674Linha(STR0050+space(13)+STR0051,1,0,nil,.F.,.F.)	//"Item/Tipo Nota"###"Consulta"
	Endif              
	If nFor == 6
		R674Linha(STR0050+space(13)+STR0052,1,0,nil,.F.,.F.)	//"Item/Tipo Nota"###"Servico"
	Endif              
	If nFor == 7
		R674Linha("Item/Tipo Nota"+space(13)+STR0053,1,0,nil,.F.,.F.)	//"GIH"
	Endif              
	
	R674Linha(Replicate('-',nLimite),1,0)                    
	R674Linha(space(20)+STR0054,1,1,nil,.F.,.F.)    	 //"Total Notas    Referencia       Vlr.Pagto     Vlr.Apres.  Vlr.Dif.  Vlr.Tx.Pgt. Vlr.Tx.Apr Vlr.Tx.Dif" // // // //"Itens           : "
	                                          
	R674Linha(STR0055+space(8)+alltrim(str(aVet[nFor][1])),1,0,nil,.F.,.F.)		//"Notas           : "
	   	 					             
	R674Linha(STR0054+space(8)+alltrim(str(aVet[nFor][2])),1,0,nil,.F.,.F.)		//"Itens           : "
	 					         	 					  
	R674Linha(STR0056+space(8)+alltrim(str(aVet[nFor][3])),1,0,nil,.F.,.F.)		//"Subitens        : "
							   			 
	R674Linha(STR0057+space(16)+;													//"Referencia R$   : "
	 					TransForm(aVet[nFor][8][1][1],pMoeda1) 						+ space(8) +;	//Referencia 
	 					TransForm(aVet[nFor][8][1][2],pMoeda1) 						+ space(1) +;	//valor Pago
		  				TransForm(aVet[nFor][8][1][3],pMoeda1) 						+ space(1) +;	//valor Apresentado 
 	   	 				TransForm(aVet[nFor][8][1][2]-aVet[nFor][8][1][3],pMoeda1) 	+ space(1) +;	//valor Diferenca  
						TransForm(aVet[nFor][8][1][4],pMoeda1) 						+ space(1) +;	//valor Tx Pago 
						TransForm(aVet[nFor][8][1][5],pMoeda1)   						+ space(1) +;	//valor Tx Apresentado
 	   	 				TransForm(aVet[nFor][8][1][4]-aVet[nFor][8][1][5],pMoeda1),1,0,nil,.F.,.F.)	//valor Tx Diferenca
	   	 					  	  
	R674Linha(STR0058+space(16)+;													//"Referencia CH   : "
	 					TransForm(aVet[nFor][8][2][1],pMoeda1) 							+ space(8) +;//Referencia 
	 					TransForm(aVet[nFor][8][2][2],pMoeda1) 							+ space(1) +;//valor Pago
		  				TransForm(aVet[nFor][8][2][3],pMoeda1) 							+ space(1) +;//valor Apresentado 
 	   	 				TransForm(aVet[nFor][8][2][2]-aVet[nFor][8][2][3],pMoeda1)		+ space(1) +;//valor Diferenca
	 					TransForm(aVet[nFor][8][2][4],pMoeda1) 							+ space(1) +;//valor Tx Pago
		  				TransForm(aVet[nFor][8][2][5],pMoeda1) 							+ space(1) +;//valor Tx Apresentado
 	   	 				TransForm(aVet[nFor][8][2][4]-aVet[nFor][8][2][5],pMoeda1),1,0,nil,.F.,.F.)	  //valor Tx Diferenca  
	   	 					  	  
	R674Linha(STR0059+space(16)+;													//"Referencia M2   : "
	 					TransForm(aVet[nFor][8][3][1],pMoeda1) 						+ space(8) +; //referencia 
	 					TransForm(aVet[nFor][8][3][2],pMoeda1) 						+ space(1) +; //valor pagamento
		  				TransForm(aVet[nFor][8][3][3],pMoeda1) 						+ space(1) +; //valor apresentado 
 	   	 				TransForm(aVet[nFor][8][3][2]-aVet[nFor][8][3][3],pMoeda1)	+ space(1) +; //valor apresentado  
	 					TransForm(aVet[nFor][8][3][4],pMoeda1) 						+ space(1) +; //valor Tx Pago
		  				TransForm(aVet[nFor][8][3][5],pMoeda1) 						+ space(1) +; //valor Tx Apresentado 
 	   	 				TransForm(aVet[nFor][8][3][4]-aVet[nFor][8][3][5],pMoeda1),1,0,nil,.F.,.F.)//valor Tx Diferenca  
	   	 					  
	R674Linha(Replicate('-',18),1,0)
	
	R674Linha(STR0060+space(34)+;													//"Procedimento    : "
	 					TransForm(aVet[nFor][8][4][2],pMoeda1) 						+ space(1) +; //valor pagamento
		  				TransForm(aVet[nFor][8][4][3],pMoeda1) 						+ space(1) +; //valor apresentado 
		  				TransForm(aVet[nFor][8][4][2]-aVet[nFor][8][4][3],pMoeda1)	+ space(1) +; //valor diferenca   
	 					TransForm(aVet[nFor][8][4][4],pMoeda1) 						+ space(1) +; //valor Tx Pago
		  				TransForm(aVet[nFor][8][4][5],pMoeda1) 						+ space(1) +; //valor Tx Apresentado 
		  				TransForm(aVet[nFor][8][4][4]-aVet[nFor][8][4][5],pMoeda1),1,0,nil,.F.,.F.)//valor Tx Diferenca   
	   	 					   			 
	R674Linha(STR0061+space(34)+;													//"Material        : "
	 					TransForm(aVet[nFor][8][5][2],pMoeda1) 						+ space(1) +; //valor Pago
		  				TransForm(aVet[nFor][8][5][3],pMoeda1) 						+ space(1) +; //valor Apresenta 
		  				TransForm(aVet[nFor][8][5][2]-aVet[nFor][8][5][3],pMoeda1)	+ space(1) +; //valor Diferenca   
	 					TransForm(aVet[nFor][8][5][4],pMoeda1) 						+ space(1) +; //valor Tx Pago
		  				TransForm(aVet[nFor][8][5][5],pMoeda1)	 						+ space(1) +; //valor Tx Apresentado 
		  				TransForm(aVet[nFor][8][5][4]-aVet[nFor][8][5][5],pMoeda1),1,0,nil,.F.,.F.)//valor Tx Diferenca
	   	 					  			 
	R674Linha(STR0062+space(34)+;													//"Medicamento     : "
	 					TransForm(aVet[nFor][8][6][2],pMoeda1) 						+ space(1) +; //valor Pago
		  				TransForm(aVet[nFor][8][6][3],pMoeda1) 			   			+ space(1) +; //valor Apresentado
		  				TransForm(aVet[nFor][8][6][2]-aVet[nFor][8][6][3],pMoeda1)	+ space(1) +; //valor Diferenca   
	 					TransForm(aVet[nFor][8][6][4],pMoeda1)							+ space(1) +; //valor Tx Pago
		  				TransForm(aVet[nFor][8][6][5],pMoeda1) 						+ space(1) +; //valor Tx Apresentado
		  				TransForm(aVet[nFor][8][6][4]-aVet[nFor][8][6][5],pMoeda1),1,0,nil,.F.,.F.)//valor Tx Diferenca   
	   	 					    			 
	R674Linha(STR0063+space(34)+;													//"Taxas           : "
	 					TransForm(aVet[nFor][8][7][2],pMoeda1) 						+ space(1) +; //valor Pago
		  				TransForm(aVet[nFor][8][7][3],pMoeda1) 						+ space(1) +; //valor Apresentado 
		  				TransForm(aVet[nFor][8][7][2]-aVet[nFor][8][7][3],pMoeda1)	+ space(1) +; //valor Diferenca   
	 					TransForm(aVet[nFor][8][7][4],pMoeda1) 						+ space(1) +; //valor Tx Pago
		  				TransForm(aVet[nFor][8][7][5],pMoeda1) 						+ space(1) +; //valor Tx Apresentado 
		  				TransForm(aVet[nFor][8][7][4]-aVet[nFor][8][7][5],pMoeda1),1,0,nil,.F.,.F.)//valor Tx Diferenca   
	   	 					     			          
	R674Linha(STR0064+space(34)+;													//"Diarias         : "
	 					TransForm(aVet[nFor][8][8][2],pMoeda1) 						+ space(1) +;	//valor Pago
		  				TransForm(aVet[nFor][8][8][3],pMoeda1) 						+ space(1) +;	//valor Apresentado
		  				TransForm(aVet[nFor][8][8][2]-aVet[nFor][8][8][3],pMoeda1)	+ space(1) +;	//valor Diferenca   
	 					TransForm(aVet[nFor][8][8][4],pMoeda1) 						+ space(1) +;	//valor Tx Pago
		  				TransForm(aVet[nFor][8][8][5],pMoeda1) 						+ space(1) +;	//valor Tx Apresentado
		  				TransForm(aVet[nFor][8][8][4]-aVet[nFor][8][8][5],pMoeda1),1,0,nil,.F.,.F.) //valor Tx Diferenca   
	   	 					  
	R674Linha(STR0065+space(34)+;													//"Ortese/Protese  : "
	 					TransForm(aVet[nFor][8][9][2],pMoeda1) 						+ space(1) +;	//valor Pago
		  				TransForm(aVet[nFor][8][9][3],pMoeda1) 						+ space(1) +;	//valor Apresentado 
		  				TransForm(aVet[nFor][8][9][2]-aVet[nFor][8][9][3],pMoeda1)	+ space(1) +;	//valor Diferenca   
	 					TransForm(aVet[nFor][8][9][4],pMoeda1) 						+ space(1) +;	//valor Tx Pago
		  				TransForm(aVet[nFor][8][9][5],pMoeda1) 						+ space(1) +;	//valor Tx Apresentado 
		  				TransForm(aVet[nFor][8][9][4]-aVet[nFor][8][9][5],pMoeda1),1,0,nil,.F.,.F.) //valor Tx Diferenca   

	R674Linha(STR0066+space(34)+;													//"Valor Total     : "
	 					TransForm(aVet[nFor][4],pMoeda1) 				+ space(1) +;		//valor pagamento
		  				TransForm(aVet[nFor][5],pMoeda1) 				+ space(1) +;		//valor apresentado 
		  				TransForm(aVet[nFor][4]-aVet[nFor][5],pMoeda1)	+ space(1) +;		//valor diferenca                     
						TransForm(aVet[nFor][6],pMoeda1) 				+ space(1) +;		//valor Tx Pago
						TransForm(aVet[nFor][7],pMoeda1)     	  		+ space(1) +;		//valor Tx Apresentado
		  				TransForm(aVet[nFor][6]-aVet[nFor][7],pMoeda1)	,1,0,nil,.F.,.F.)	//valor Tx Diferenca
	   	 					  
	nFor++
Enddo
	
nFor := 5
While nFor <= 7                
		nTotNotas += aVet[nFor][1] // total notas
		nTotItens += aVet[nFor][2] // total itens
		nTotSubIt += aVet[nFor][3] // total subitens         
     	nFor++
Enddo

R674Linha(space(20)+Replicate('-',nLimite),4,0,nil,.F.,.F.)      
R674Linha(space(20)+STR0067,1,0,nil,.F.,.F.)										//"Resumo Geral"
R674Linha(space(20)+Replicate('-',nLimite),1,0,nil,.F.,.F.)      
R674Linha(space(20)+STR0068+str(nTotNotas,6)+space(5)+"| "+STR0069+str(aCriticas[1][1],6)+space(4)+"| "+STR0070+alltrim(str(nTotNotas-aCriticas[1][1])),1,0,nil,.F.,.F.)					//"Total Notas       :"###"Notas Divergentes  :"###"Notas OK          :"
R674Linha(space(20)+STR0071+str(nTotItens,6)+space(5)+"| "+"Itens Divergentes  :"+str(aCriticas[1][2],6)+space(4)+"| "+STR0072+alltrim(str(nTotItens-aCriticas[1][2])),1,0,nil,.F.,.F.)	//"Total Itens       :"###"Itens OK          :"
R674Linha(space(20)+STR0073+str(nTotSubIt,6),1,0,nil,.F.,.F.)						//"Total SubItens    :"
R674Linha(space(20)+Replicate('-',nLimite),1,0,nil,.F.,.F.)
R674Linha(space(20)+STR0074+TransForm(aVet[1],pMoeda2),1,0,nil,.F.,.F.)			//"Total Pago        :"
R674Linha(space(20)+STR0075+TransForm(aVet[2],pMoeda2),1,0,nil,.F.,.F.)			//"Total Apresentado :"
R674Linha(space(20)+STR0076+TransForm(aVet[1]-aVet[2],pMoeda2),1,0,nil,.F.,.F.)	//"Total Diferencas  :"
R674Linha(space(20)+STR0077+TransForm(aVet[3],pMoeda2),1,0,nil,.F.,.F.)			//"Total Tx Pago     :"
R674Linha(space(20)+STR0078+TransForm(aVet[4],pMoeda2),1,0,nil,.F.,.F.)			//"Total Tx Apresent :"
R674Linha(space(20)+STR0079+TransForm(aVet[3]-aVet[4],pMoeda2),1,0,nil,.F.,.F.)	//"Total Tx Diferenc :"
R674Linha(space(20)+Replicate('-',nLimite),1,0,nil,.F.,.F.) 
    
Return                                          
/*
эээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээ
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
╠╠иммммммммммямммммммммммммммкммммммяммммммммммммммммммкммммммяммммммммммм╩╠╠
╠╠╨Programa  ЁPlsImpTEm      ╨Autor ЁDaher             ╨ Data Ё 22/07/05  ╨╠╠
╠╠лммммммммммьмммммммммммммммйммммммоммммммммммммммммммйммммммоммммммммммм╧╠╠
╠╠╨Desc.     Ё				                                              ╨╠╠
╠╠лммммммммммьмммммммммммммммммммммммммммммммммммммммммммммммммммммммммммм╧╠╠
╠╠╨Uso       Ё AP                                                         ╨╠╠
╠╠хммммммммммомммммммммммммммммммммммммммммммммммммммммммммммммммммммммммм╪╠╠
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
ъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъ
*/
static Function PlsImpTEm()                                           
R674Linha(space(39)+STR0080+;		//"Total Empresa: "
				TransForm(aCurrent[1][1],pMoeda1)					+ space(1) + ;//valor Pago
				TransForm(aCurrent[1][2],pMoeda1)  					+ space(1) + ;//valor apresentado 
				TransForm(aCurrent[1][1]-aCurrent[1][2],pMoeda1)	+ space(1) + ;//valor diferenca
				TransForm(aCurrent[1][3],pMoeda1)					+ space(1) + ;//valor Tx Pago
				TransForm(aCurrent[1][4],pMoeda1)					+ space(1) + ;//valor Tx apresentado 
 				TransForm(aCurrent[1][3]-aCurrent[1][4],pMoeda1),2,0)	 		   //valor Tx diferenca
aCurrent[1] := __SIZEACURREMP
return

/*
эээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээ
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
╠╠иммммммммммямммммммммммммммкммммммяммммммммммммммммммкммммммяммммммммммм╩╠╠
╠╠╨Programa  ЁPlsImpTTG      ╨Autor ЁAlexander         ╨ Data Ё 09/11/05  ╨╠╠
╠╠лммммммммммьмммммммммммммммйммммммоммммммммммммммммммйммммммоммммммммммм╧╠╠
╠╠╨Desc.     Ё Total tipo guia                                            ╨╠╠
╠╠лммммммммммьмммммммммммммммммммммммммммммммммммммммммммммммммммммммммммм╧╠╠
╠╠╨Uso       Ё AP                                                         ╨╠╠
╠╠хммммммммммомммммммммммммммммммммммммммммммммммммммммммммммммммммммммммм╪╠╠
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
ъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъ
*/
static Function PlsImpTTG(cTipGui,nI)                                           
LOCAL cMsg := AllTrim(BCL->(Posicione("BCL",1,xFilial("BCL")+aMatBD6[nI,17]+cTipGui,"BCL_DESCRI")))

R674Linha(Space(46-Len(AllTrim(cMsg)))+"Total "+cMsg+": "+;
				TransForm(aCurrent[3][1],pMoeda1)					+ space(1) + ;//valor Pago
				TransForm(aCurrent[3][2],pMoeda1)  					+ space(1) + ;//valor apresentado 
				TransForm(aCurrent[3][1]-aCurrent[3][2],pMoeda1)	+ space(1) + ;//valor diferenca
				TransForm(aCurrent[3][3],pMoeda1)					+ space(1) + ;//valor Tx Pago
				TransForm(aCurrent[3][4],pMoeda1)					+ space(1) + ;//valor Tx apresentado 
 				TransForm(aCurrent[3][3]-aCurrent[3][4],pMoeda1),2,0)	 		   //valor Tx diferenca
aCurrent[3] := __SIZEACURREMP
return
/*
эээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээ
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
╠╠иммммммммммямммммммммммммммкммммммяммммммммммммммммммкммммммяммммммммммм╩╠╠
╠╠╨Programa  ЁPlsImpTFP      ╨Autor ЁAlexander         ╨ Data Ё 09/11/05  ╨╠╠
╠╠лммммммммммьмммммммммммммммйммммммоммммммммммммммммммйммммммоммммммммммм╧╠╠
╠╠╨Desc.     ЁTotal pago,glosado,reconsiderad                             ╨╠╠
╠╠лммммммммммьмммммммммммммммммммммммммммммммммммммммммммммммммммммммммммм╧╠╠
╠╠╨Uso       Ё AP                                                         ╨╠╠
╠╠хммммммммммомммммммммммммммммммммммммммммммммммммммммммммммммммммммммммм╪╠╠
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
ъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъ
*/              
static Function PlsImpTFP(cMsg)      
R674Linha(Space(46-Len(cMsg))+"Total "+cMsg+": "+;
				TransForm(aCurrent[4][1],pMoeda1)					+ space(1) + ;//valor Pago
				TransForm(aCurrent[4][2],pMoeda1)  					+ space(1) + ;//valor apresentado 
				TransForm(aCurrent[4][1]-aCurrent[4][2],pMoeda1)	+ space(1) + ;//valor diferenca
				TransForm(aCurrent[4][3],pMoeda1)					+ space(1) + ;//valor Tx Pago
				TransForm(aCurrent[4][4],pMoeda1)					+ space(1) + ;//valor Tx apresentado 
 				TransForm(aCurrent[4][3]-aCurrent[4][4],pMoeda1),2,0)	 		   //valor Tx diferenca
 				
aCurrent[4] := __SIZEACURREMP

Return
/*/
эээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээ
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
╠╠зддддддддддбддддддддддддбдддддддбдддддддддддддддддддбддддддбдддддддддддд©╠╠
╠╠ЁPrograma  Ё PLSCRITIC  Ё Autor Ё Alexander         Ё Data Ё 21.12.2006 Ё╠╠
╠╠цддддддддддеддддддддддддадддддддадддддддддддддддддддаддддддадддддддддддд╢╠╠
╠╠ЁDescri┤└o Ё F3 da listagem das criticas			                      Ё╠╠
╠╠цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢╠╠
╠╠ЁUso       Ё F3 BYP                                                     Ё╠╠
╠╠цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢╠╠
╠╠ЁParametrosЁ Padrao do mBrowse                                          Ё╠╠
╠╠юддддддддддадддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды╠╠
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
ъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъ
/*/
Function PLSCRITIC(cDado,lTela)
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Define variaveis...                                                      Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды

	Static objCENFUNLGP := CENFUNLGP():New()

LOCAL oDlg
LOCAL oCritica
LOCAL cSQL
LOCAL nInd                     
LOCAL nPos                                                           
LOCAL nQtd		:= 0
LOCAL bChk		:= {|| nQtd := PLSCONT(aLista) }
LOCAL aLista    := {}
LOCAL aCriticas := {}
LOCAL nOpca     := 0
LOCAL bOK       := { || nOpca := K_OK, oDlg:End() }
LOCAL bCancel   := { || oDlg:End() }
DEFAULT lTela 	:= .T.                   
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё coloca virgula no comeco (caso tenha inicializador padrao)               Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
cDado := AllTrim(cDado)
If Subs(cDado,Len(cDado),1) != "," .And. cDado != ""
   cDado += ","
EndIf
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Carrega as criticas														 Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
cSql := " SELECT BCT_PROPRI+BCT_CODGLO AS CODGLO,BCT_DESCRI " 
cSql += "   FROM "+BCT->( RetSQLName("BCT") )
cSql += "  WHERE BCT_FILIAL = '" + xFilial("BCT") + "' "          
cSql += "    AND BCT_PROPRI <> '5' "
cSql += "  	 AND D_E_L_E_T_ <> '*' "           
cSql += "  	 ORDER BY BCT_DESCRI "           
PLSQUERY(cSQL,"TRBBCT")
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Monta as criticas														 Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
While !TRBBCT->( Eof() )
   AaDd( aCriticas , { TRBBCT->CODGLO,TRBBCT->BCT_DESCRI } )
   TRBBCT->( DbSkip() )
EndDo           
TRBBCT->( DbCloseArea() )
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Problema no bin por isso foi colocado a abertura desta area				 Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
DbSelectArea("BA1")
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Verifica as criticas													 Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
For nInd := 1 To Len(aCriticas)
	AaDd( aLista , { aCriticas[nInd,1],aCriticas[nInd,2],If(aCriticas[nInd,1] $ cDado,.T.,.F.) } )
Next
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Se exibi a tela															 Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
If lTela
   DEFINE MSDIALOG oDlg TITLE STR0046 FROM ndLinIni,ndColIni TO ndLinFin,ndColFin OF GetWndDefault()	//"Criticas"

   @ 020,012 SAY oSay PROMPT STR0081 SIZE 300,010 OF oDlg PIXEL COLOR CLR_HBLUE							//"Selecione a(s) criticas(s) que podem(rao) impedir a importacao"

   oCritica := TcBrowse():New( 035, 012, 330, 150,,,, oDlg,,,,,,,,,,,, .F.,, .T.,, .F., )
   oCritica:AddColumn(TcColumn():New(" "		,{ || IF(aLista[oCritica:nAt,3],LoadBitmap( GetResources(), "LBOK" ),LoadBitmap( GetResources(), "LBNO" )) },"@c",nil,nil,nil,015,.T.,.T.,nil,nil,nil,.T.,nil))     
   oCritica:AddColumn(TcColumn():New(STR0082	,{ || OemToAnsi(aLista[oCritica:nAt,1]) },"@!",nil,nil,nil,020,.F.,.F.,nil,nil,nil,.F.,nil))			//"Codigo"
   oCritica:AddColumn(TcColumn():New(STR0083	,{ || OemToAnsi(aLista[oCritica:nAt,2]) },"@C",nil,nil,nil,200,.F.,.F.,nil,nil,nil,.F.,nil))				//"Descricao"
   
//-------------------------------------------------------------------
//  LGPD
//-------------------------------------------------------------------
	if objCENFUNLGP:isLGPDAt()
		aCampos := {.F.,"BCT_PROPRI+BCT_CODGLO","BCT_DESCRI"}
		aBls := objCENFUNLGP:getTcBrw(aCampos)

		oCritica:aObfuscatedCols := aBls
	endif
   
   oCritica:SetArray(aLista)         
   oCritica:bLDblClick := { || Eval(bChk) , Iif( nQtd<=20 .Or. aLista[oCritica:nAt,3] , aLista[oCritica:nAt,3] := IF(aLista[oCritica:nAt,3],.F.,.T.) , .F. ) }

   ACTIVATE MSDIALOG oDlg ON INIT EnChoiceBar( oDlg,bOK,bCancel,.F.,{} )
Else
   nOpca := K_OK
Endif
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё If ok																	 Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
If nOpca == K_OK
   cDado := ""
   For nInd := 1 To Len(aLista)
       If aLista[nInd,3]
          cDado += aLista[nInd,1]+","
       Endif   
   Next
Endif
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё tira a virgula do final                                                  Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
If Subs(cDado,Len(cDado),1) == ","
   cDado := Subs(cDado,1,Len(cDado)-1)
EndIf                
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Fim da rotina															 Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
Return(cDado)
/*                                     
эээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээ
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
╠╠иммммммммммямммммммммммммммкммммммяммммммммммммммммммкммммммяммммммммммм╩╠╠
╠╠╨Programa  ЁPLSCONT	     ╨Autor ЁAlexander         ╨ Data Ё 22/12/06  ╨╠╠
╠╠лммммммммммьмммммммммммммммйммммммоммммммммммммммммммйммммммоммммммммммм╧╠╠
╠╠╨Desc.     Ё Conta itens marcados da matriz							  ╨╠╠
╠╠хммммммммммомммммммммммммммммммммммммммммммммммммммммммммммммммммммммммм╪╠╠
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
ъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъ
*/
Static Function PLSCONT(aLista)
LOCAL nI
LOCAL nQtd := 0

For nI := 1 To Len(aLista) 
    If aLista[nI,3] 
	   nQtd++
	EndIf   
Next 
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Fim da rotina															 Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
Return nQtd
/*                                     
эээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээ
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
╠╠иммммммммммямммммммммммммммкммммммяммммммммммммммммммкммммммяммммммммммм╩╠╠
╠╠╨Programa  ЁPlsImpTpG      ╨Autor ЁAlexander         ╨ Data Ё 07/11/05  ╨╠╠
╠╠лммммммммммьмммммммммммммммйммммммоммммммммммммммммммйммммммоммммммммммм╧╠╠
╠╠╨Desc.     Ё tp guia	                                          		  ╨╠╠
╠╠лммммммммммьмммммммммммммммммммммммммммммммммммммммммммммммммммммммммммм╧╠╠
╠╠╨Uso       Ё AP                                                         ╨╠╠
╠╠хммммммммммомммммммммммммммммммммммммммммммммммммммммммммммммммммммммммм╪╠╠
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
ъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъ
*/
static Function PlsImpTpG(nTipo,nI)      
     If nTipo == 2 .Or. nTipo == 3
	    R674Linha(Replicate('-',nLimite),1,0)
	 EndIf    
     R674Linha(BCL->(Posicione("BCL",1,xFilial("BCL")+aMatBD6[nI,17]+aMatBD6[nI,4],"BCL_DESCRI")),1,0)
     If nTipo == 1 .Or. nTipo == 3 
	    R674Linha(Replicate('-',nLimite),1,0)
	 EndIf    
Return
