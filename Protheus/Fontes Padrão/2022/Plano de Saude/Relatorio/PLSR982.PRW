#INCLUDE "PLSR982.CH"
#include "PROTHEUS.CH"
#include "PLSMGER.CH"
#include "topconn.CH"
static objCENFUNLGP := CENFUNLGP():New() 
static lAutoSt := .F.

/*/
ээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээ
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
╠╠зддддддддддбдддддддддбдддддддбддддддддддддддддддддддддбддддддбдддддддддд©╠╠╠
╠╠ЁFuncao    Ё PLSR982 Ё Autor Ё Thiago Machado Correa  Ё Data Ё 27/08/04 Ё╠╠╠
╠╠цддддддддддедддддддддадддддддаддддддддддддддддддддддддаддддддадддддддддд╢╠╠╠
╠╠ЁDescricao Ё Relatorio de acompanhamento mensal dos Auto-Gerados		  Ё╠╠╠
╠╠цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢╠╠╠
╠╠ЁSintaxe   Ё PLSR982()                                                  Ё╠╠╠
╠╠цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢╠╠╠
╠╠Ё Uso      Ё Advanced Protheus                                          Ё╠╠╠
╠╠цддддддддддадддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢╠╠╠
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
ъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъ
/*/

Function PLSR982(lAuto)

//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Define variaveis...									                     Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
Local aOrdens := {}   
Local cAlias  := "BD7"
Local cOperad := ""
Local cMesIni := ""
Local cAnoIni := ""
Local cMesFim := ""
Local cAnoFim := ""
Local cSeqIni := ""
Local cSeqFim := ""
Local cPgtIni := ""
Local cPgtFim := ""
Local cRdaIni := ""
Local cRdaFim := ""     
Local cTmp    := ""
Local cTitOri := ""
Local nTmp    := 0
Local nQtdRel := 0
Local nListar := 0
Local nOpca   := 0

Default lAuto := .F.

Private wnrel
Private cDesc1      := STR0001 //"Acompanhamento mensal dos Auto-Gerados"
Private cDesc2      := ""
Private cDesc3      := ""
Private cTitulo     := STR0001 //"Acompanhamento mensal dos Auto-Gerados"
Private cCabec1     := STR0002+"                 "+STR0003+"                  "+STR0004+"       "+STR0005+"                        "+STR0006+"      "+STR0007+"                "+STR0008 //"Usuario"###"Nome do Usuario"###"Procedimento"###"Descricao"###"Tipo"###"Data"###"Valor"
Private cCabec2     := ""
Private cNomeProg   := "PLSR982"
Private cPerg       := "PLR982"
Private Li          := 01
Private m_pag       := 1
Private aReturn     := { STR0009, 1,STR0010, 1, 1, 1, "",1 } //"Zebrado"###"Administracao"
Private cTamanho	:= "G"
Private lDicion     := .F.
Private lCompres    := .F.
Private lCrystal    := .F.
Private lFiltro     := .T.
Private lAbortPrint := .F.                                                                       
Private aStru		:= {}
Private nColuna     := 00
Private nLimite     := 220
Private nPagina     := 1

lAutoSt := lAuto

//-- LGPD ----------
if !lAuto .ANd. !objCENFUNLGP:getPermPessoais()
	objCENFUNLGP:msgNoPermissions()
	Return
Endif
//------------------

//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Ajusta SX1...							                                 Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
AjustaSX1()

//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Chama SetPrint                                                           Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
wnrel := "PLSR982"
If !lauto
	wnRel := SetPrint(cAlias, wnRel,cPerg,@cTitulo,cDesc1,cDesc2,cDesc3,lDicion,aOrdens,,cTamanho,,lFiltro, lCrystal)
endIf
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Verifica se foi cancelada a operacao                                     Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
If !lAuto .AND. nLastKey  == 27 
   Return
Endif

//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Acessa parametros do relatorio...                                        Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
Pergunte(cPerg,.f.)
cOperad := mv_par01
cMesIni := mv_par02
cAnoIni := mv_par03
cMesFim := mv_par04
cAnoFim := mv_par05
cSeqIni := mv_par06
cSeqFim := mv_par07
cPgtIni := mv_par08
cPgtFim := mv_par09
cRdaIni := mv_par10
cRdaFim := mv_par11
nListar := mv_par12

if lauto
	cOperad := "0001"
	cMesIni := "12"
	cAnoIni := "2020"
	cMesFim := "01"
	cAnoFim := "2021"
	cSeqIni := "000"
	cSeqFim := "001"
	cPgtIni := "  "
	cPgtFim := "ZZ"
	cRdaIni := "  "
	cRdaFim := "ZZ"
	nListar := nAutoList
endIf

cTmp := cAnoIni+cMesIni

While cTmp <= cAnoFim+cMesFim

	cTmp := substr(dtos(stod(cTmp+"15")+30),1,6)

	nQtdRel++
EndDo

cTmp := cAnoIni+cMesIni
cTitOri := cTitulo

//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Configura impressora                                                     Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
If !lAuto
	SetDefault(aReturn,cAlias)       
endIf
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Emite relat╒rio                                                          Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
For nTmp := 1 to nQtdRel
	If !lAuto
		RptStatus({|| PLSR982IMP(cOperad,cTmp,cRdaIni,cRdaFim,cTitOri,cSeqIni,cSeqFim,cPgtIni,cPgtFim,nListar) },cDesc1,STR0011+"... "+STR0015+" "+substr(cTmp,5,2)+"/"+substr(cTmp,1,4)) //"Processando"###"Competencia"
	else
		PLSR982IMP(cOperad,cTmp,cRdaIni,cRdaFim,cTitOri,cSeqIni,cSeqFim,cPgtIni,cPgtFim,nListar)
	endIf
	cTmp := substr(dtos(stod(cTmp+"15")+30),1,6)
Next	

//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Libera impressao                                                         Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
If !lAuto .AND. aReturn[5] == 1 
    Set Printer To
    Ourspool(wnRel)
Endif

//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Fim da Rotina Principal...                                               Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
Return

/*/
ээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээ
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
╠╠здддддддддддбддддддддддбдддддддбдддддддддддддддддддддддбддддддбдддддддддд©╠╠
╠╠ЁPrograma   ЁPLSR982IMPЁ Autor Ё Thiago Machado Correa Ё Data Ё 27/08/04 Ё╠╠
╠╠цдддддддддддеддддддддддадддддддадддддддддддддддддддддддаддддддадддддддддд╢╠╠
╠╠ЁDescricao  Ё Imprime detalhe do relatorio...                            Ё╠╠
╠╠юдддддддддддадддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды╠╠
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
/*/

Static Function PLSR982IMP(cOperad,cCompet,cRdaIni,cRdaFim,cTitOri,cSeqIni,cSeqFim,cPgtIni,cPgtFim,nListar)

//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Inicializa variaveis                                                     Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
Local cSQL     := ""
Local cRda     := ""
Local cCodEsp  := ""
Local cLinha   := ""
Local cSequen  := ""
Local cPagto   := ""
Local cSeqAtu  := ""
Local cPgtAtu  := ""
Local cRdaAtu  := ""
Local cEspAtu  := ""
Local cChave   := ""
Local nQtdReg  := 0  
Local nTotEBrt := 0
Local nTotEDes := 0
Local nTotRBrt := 0
Local nTotRDes := 0
Local nTotGBrt := 0
Local nTotGDes := 0
Local nVal     := 0
Local nTotEsp  := 0
Local nTotRda  := 0
Local nTotLot  := 0
Local nTotSeq  := 0
Local nTotGer  := 0
Local nQtdLin  := 64
Local cBD7Name := RetSQLName("BD7")
Local cMvNORM  := GetMv("MV_NORM")

cTitulo := alltrim(Upper(cTitOri)) + IIF(nListar==1," "+STR0013," "+STR0014) + "   -   "+STR0015+": " + substr(cCompet,5,2) + "/" + substr(cCompet,1,4) //"GLOSADOS"###"PAGOS"###"Competencia"

//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Seleciona indice                                                         Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
BAU->(DbSetOrder(1))
BAQ->(DbSetOrder(1))
BR8->(DbSetOrder(1))
BD7->(DbSetOrder(1))
BA1->(DbSetOrder(2))

//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Prepara Query para Regua...                                              Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
cSQL := " SELECT COUNT(*) QTD FROM " + cBD7Name
cSQL += " WHERE BD7_FILIAL = '" + xFilial("BD7") + "' AND BD7_BLQAUG IN ('1','2') AND "
cSQL +=       " BD7_CODOPE = '" + cOperad        + "' AND "
If nListar == 1
	cSQL += " 	BD7_PERBLQ = '"  + cCompet + "' AND "
	cSQL += " 	BD7_SEQBLQ >= '" + cSeqIni + "' AND "
	cSQL += " 	BD7_SEQBLQ <= '" + cSeqFim + "' AND "
	cSQL += " 	BD7_PGTBLQ >= '" + cPgtIni + "' AND "
	cSQL += " 	BD7_PGTBLQ <= '" + cPgtFim + "' AND "
Else
	cSQL += " 	BD7_PERDES = '"  + cCompet + "' AND "
	cSQL += " 	BD7_SEQDES >= '" + cSeqIni + "' AND "
	cSQL += " 	BD7_SEQDES <= '" + cSeqFim + "' AND "
	cSQL += " 	BD7_PGTDES >= '" + cPgtIni + "' AND "
	cSQL += " 	BD7_PGTDES <= '" + cPgtFim + "' AND "
EndIf
cSQL += " BD7_CODRDA >= '" + cRdaIni + "' AND "
cSQL += " BD7_CODRDA <= '" + cRdaFim + "' AND "
cSQL += " D_E_L_E_T_ <> '*' "

//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Executa a query...								                         Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
PLSQuery(cSQL,"TMP")

//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Prepara Regua...    			                                         Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
nQtdReg := TMP->QTD
If !lAutoSt
	SetRegua(nQtdReg)
endIF
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Seleciona registros                                                      Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
cSQL := " SELECT BD7_CODOPE, BD7_CODLDP, BD7_CODPEG, BD7_NUMERO, BD7_ORIMOV, BD7_SEQUEN, BD7_CODPAD, BD7_CODPRO, BD7_SEQBLQ, BD7_PGTBLQ, BD7_SEQDES, BD7_PGTDES, BD7_CODRDA, BD7_VLRPAG, BD7_VLRBLO, BD7_CODESP, BD7_BLQAUG, BD7_BLOPAG FROM " + cBD7Name
cSQL += " WHERE BD7_FILIAL = '" + xFilial("BD7") + "' AND BD7_BLQAUG IN ('1','2') AND "
cSQL +=       " BD7_CODOPE = '" + cOperad        + "' AND "
If nListar == 1
	cSQL += " 	BD7_PERBLQ = '"  + cCompet + "' AND "
	cSQL += " 	BD7_SEQBLQ >= '" + cSeqIni + "' AND "
	cSQL += " 	BD7_SEQBLQ <= '" + cSeqFim + "' AND "
	cSQL += " 	BD7_PGTBLQ >= '" + cPgtIni + "' AND "
	cSQL += " 	BD7_PGTBLQ <= '" + cPgtFim + "' AND "
Else
	cSQL += " 	BD7_PERDES = '"  + cCompet + "' AND "
	cSQL += " 	BD7_SEQDES >= '" + cSeqIni + "' AND "
	cSQL += " 	BD7_SEQDES <= '" + cSeqFim + "' AND "
	cSQL += " 	BD7_PGTDES >= '" + cPgtIni + "' AND "
	cSQL += " 	BD7_PGTDES <= '" + cPgtFim + "' AND "
EndIf
cSQL += " BD7_CODRDA >= '" + cRdaIni + "' AND "
cSQL += " BD7_CODRDA <= '" + cRdaFim + "' AND "
cSQL += " D_E_L_E_T_ <> '*' "
If nListar == 1
	cSQL += " ORDER BY BD7_SEQBLQ, BD7_PGTBLQ, BD7_CODRDA, BD7_CODESP, BD7_OPEUSR, BD7_CODEMP, BD7_MATRIC, BD7_TIPREG "
Else
	cSQL += " ORDER BY BD7_SEQDES, BD7_PGTDES, BD7_CODRDA, BD7_CODESP, BD7_OPEUSR, BD7_CODEMP, BD7_MATRIC, BD7_TIPREG "
Endif

If nListar == 1
	cSequen  := "TMP->BD7_SEQBLQ"
	cPagto   := "TMP->BD7_PGTBLQ"
Else
	cSequen  := "TMP->BD7_SEQDES"
	cPagto   := "TMP->BD7_PGTDES"
Endif

//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Fecha o arquivo TMP, para abri-lo com a query                            Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
TMP->(dbCloseArea())
PLSQuery(cSQL,"TMP")

//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Imprime cabecalho...				                                     Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
If !lAutost .AND. nQtdReg > 0
	Cabec(cTitulo,cCabec1,cCabec2,cNomeProg,cTamanho,GetMv("MV_NORM"))
Endif

//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Processa TMP...					                                         Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
While ! TMP->(Eof())

   //зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
   //Ё Incrementa Regua...			                                         Ё
   //юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
   	if !lAutost
   		IncRegua()
	endIf
   //зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
   //Ё Verifica se foi cancelada a impressao                                 Ё
   //юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
   If !lAutost .AND. Interrupcao(lAbortPrint)
       Exit
   Endif                       

   //здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
   //Ё Imprime cabecalho...				                                     	Ё
   //юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
   If !lAutost .AND. Li+3 > nQtdLin
	   Cabec(cTitulo,cCabec1,cCabec2,cNomeProg,cTamanho,cMvNORM)
   Endif                                                                        
  	   
   @ Li,nColuna pSay STR0016+": " + &cSequen //"Sequencial"
   Li ++ 		
   @ Li,nColuna pSay replicate("-",nLimite)
   Li ++ 		               
   @ Li,nColuna pSay ""
   Li ++ 

   cSeqAtu := &cSequen

   While (&cSequen == cSeqAtu) .and. TMP->(!Eof())
       
	   //здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	   //Ё Imprime cabecalho...				                                     	Ё
	   //юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
	   If !lAutost .AND. Li+3 > nQtdLin
		   Cabec(cTitulo,cCabec1,cCabec2,cNomeProg,cTamanho,cMvNORM)
	   Endif                                                                        
	
	   @ Li,nColuna pSay STR0017+": " + &cPagto //"Lote de Pagamento"
	   Li ++ 		
	   @ Li,nColuna pSay replicate("-",nLimite)
	   Li ++ 		               
	   @ Li,nColuna pSay ""
	   Li ++ 

   	   cPgtAtu := &cPagto
   	   
	   While (&cSequen == cSeqAtu) .and. (&cPagto == cPgtAtu) .and. TMP->(!Eof())

		   //зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
		   //Ё Pocisiona Rda...							                             Ё
		   //юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
		   If ! BAU->(DBSeek(xFilial("BAU")+TMP->BD7_CODRDA))
		       TMP->(DBSkip())
		       Loop
		   Endif    
		   
		   //здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
		   //Ё Imprime cabecalho...				                                     	Ё
		   //юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
		   If !lAutost .AND. Li+3 > nQtdLin
			   Cabec(cTitulo,cCabec1,cCabec2,cNomeProg,cTamanho,cMvNORM)
		   Endif                                                                        
		
		   @ Li,nColuna pSay STR0018+": " + BAU->BAU_CODIGO + " - " + BAU->BAU_NOME //"Rede de Atendimento"
		   Li ++ 		
		   @ Li,nColuna pSay replicate("-",nLimite)
		   Li ++ 		               
		   @ Li,nColuna pSay ""
		   Li ++ 
	
	   	   cRdaAtu := TMP->BD7_CODRDA
	   	   
		   While (&cSequen == cSeqAtu) .and. (&cPagto == cPgtAtu) .and. (TMP->BD7_CODRDA==cRdaAtu) .and. TMP->(!Eof())

			   //зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
			   //Ё Pocisiona Especialidade...				                             Ё
			   //юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
			   If ! BAQ->(DBSeek(xFilial("BAQ")+cOperad+TMP->BD7_CODESP))
			       TMP->(DBSkip())
			       Loop
			   Endif    
					   
			   //здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
			   //Ё Imprime cabecalho...				                                     	Ё
			   //юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
			   If !lAutost .AND. Li+3 > nQtdLin
				   Cabec(cTitulo,cCabec1,cCabec2,cNomeProg,cTamanho,cMvNORM)
			   Endif                                                                        
			
			   @ Li,nColuna pSay STR0019+": " + BAQ->BAQ_CODESP + " - " + BAQ->BAQ_DESCRI //"Especialidade"
			   Li ++ 		
			   @ Li,nColuna pSay replicate("-",nLimite)
			   Li ++ 		               
			   @ Li,nColuna pSay ""
			   Li ++ 
		
		   	   cEspAtu := TMP->BD7_CODESP
		   	   
			   While (&cSequen == cSeqAtu) .and. (&cPagto == cPgtAtu) .and. (TMP->BD7_CODRDA==cRdaAtu) .and. (TMP->BD7_CODESP==cEspAtu) .and. TMP->(!Eof())
		
				   //зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
				   //Ё Pocisiona Tabela Padrao...				                             Ё
				   //юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
				   If ! BR8->(DBSeek(xFilial("BR8")+TMP->BD7_CODPAD+TMP->BD7_CODPRO))
				       TMP->(DBSkip())
				       Loop
				   Endif    
				   
  				   //зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
				   //Ё Posiciona BD7...														 Ё
		           //юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
		           If ! BD7->(DbSeek(xFilial("BD7")+TMP->(BD7_CODOPE+BD7_CODLDP+BD7_CODPEG+BD7_NUMERO+BD7_ORIMOV+BD7_SEQUEN)))
				       TMP->(DBSkip())
				       Loop
				   Endif    
					
  				   //зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
				   //Ё Posiciona BA1...														 Ё
		           //юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
		           If ! BA1->(DbSeek(xFilial("BA1")+BD7->(BD7_OPEUSR+BD7_CODEMP+BD7_MATRIC+BD7_TIPREG)))
				       TMP->(DBSkip())
				       Loop
				   Endif    

	   	       	   cLinha := BA1->BA1_CODINT + "." + BA1->BA1_CODEMP + "." + BA1->BA1_MATRIC + "." + BA1->BA1_TIPREG + "-" + BA1->BA1_DIGITO
                   cLinha += Space(3)
                   cLinha += substr(BA1->BA1_NOMUSR,1,30)
                   cLinha += Space(3)
                   cLinha += BR8->BR8_CODPSA
                   cLinha += Space(3)
                   cLinha += substr(BR8->BR8_DESCRI,1,30)
                   cLinha += Space(3)
                   
                   If nListar == 1
					   If TMP->BD7_BLQAUG == "1"
		                   cLinha += STR0020 //"Acumula"
		                   cLinha += Space(3)
					   Else
		                   cLinha += STR0021 //"Glosa"
		                   cLinha += Space(5)
					   Endif
                   Else
	                   cLinha += Space(10)
                   Endif

                   cLinha += dtoc(BD7->BD7_DATPRO)
                   cLinha += Space(3)

				   nVal := 0

				   cChave := &cSequen + &cPagto + TMP->BD7_CODRDA + TMP->BD7_CODESP
				   cChave += TMP->(BD7_CODOPE+BD7_CODLDP+BD7_CODPEG+BD7_NUMERO+BD7_ORIMOV+BD7_SEQUEN)

				   While cChave == (&cSequen+&cPagto+TMP->(BD7_CODRDA+BD7_CODESP+BD7_CODOPE+BD7_CODLDP+BD7_CODPEG+BD7_NUMERO+BD7_ORIMOV+BD7_SEQUEN)) .and. TMP->(!Eof())
					  
					   If TMP->BD7_BLOPAG == "1"
						   nVal += TMP->BD7_VLRBLO
                       Else
						   nVal += TMP->BD7_VLRPAG
					   Endif						

				       TMP->(DBSkip())
                   EndDo
                   
				   cLinha += Transform(nVal,"@E 999,999,999.99")

				   //зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
				   //Ё Imprime cabecalho...			                					 Ё
				   //юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
				   If !lAutost .AND. Li > nQtdLin
					   Cabec(cTitulo,cCabec1,cCabec2,cNomeProg,cTamanho,cMvNORM)
				   Endif
				   
				   @ Li,nColuna pSay cLinha
				   Li ++ 
		
				   //зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
				   //Ё Acumula valores                                                   Ё
				   //юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
				   nTotEsp += nVal
		       EndDo  
		       
			   //зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
			   //Ё Imprime cabecalho...			                				  	 Ё
			   //юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
			   If !lAutost .AND. Li+4 > nQtdLin
			       Cabec(cTitulo,cCabec1,cCabec2,cNomeProg,cTamanho,cMvNORM)
			   Endif  
			   
			   @ Li,nColuna pSay ""
			   Li ++ 
			   @ Li,nColuna pSay STR0022+": "  + Space(106) + Transform(nTotEsp,"@E 999,999,999.99") //"Total da Especialidade"
			   Li ++ 
			   @ Li,nColuna pSay replicate("-",nLimite)
			   Li ++
			   @ Li,nColuna pSay ""
			   Li ++

			   //зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
			   //Ё Acumula valores                                                   Ё
			   //юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
			   nTotRda += nTotEsp
			   nTotEsp := 0
	       
	       EndDo  
	       
		   //зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
		   //Ё Imprime cabecalho...			                				  	 Ё
		   //юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
		   If !lAutost .AND. Li+3 > nQtdLin
		       Cabec(cTitulo,cCabec1,cCabec2,cNomeProg,cTamanho,cMvNORM)
		   Endif  
		   
		   @ Li,nColuna pSay STR0023+": "  + Space(116) + Transform(nTotRda,"@E 999,999,999.99") //"Total da Rda"
		   Li ++ 
		   @ Li,nColuna pSay replicate("-",nLimite)
		   Li ++
		   @ Li,nColuna pSay ""
		   Li ++

		   //зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
		   //Ё Acumula valores                                                   Ё
		   //юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
		   nTotLot += nTotRda
		   nTotRda := 0       
		   
	   EndDo  

	   //зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	   //Ё Imprime cabecalho...			                				  	 Ё
	   //юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
	   If !lAutost .AND. Li+3 > nQtdLin
	       Cabec(cTitulo,cCabec1,cCabec2,cNomeProg,cTamanho,cMvNORM)
	   Endif  
	   
	   @ Li,nColuna pSay STR0024+": "  + Space(102) + Transform(nTotLot,"@E 999,999,999.99") //"Total do Lote de Pagamento"
	   Li ++ 
	   @ Li,nColuna pSay replicate("-",nLimite)
	   Li ++
	   @ Li,nColuna pSay ""
	   Li ++

	   //зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	   //Ё Acumula valores                                                   Ё
	   //юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
	   nTotSeq += nTotLot
	   nTotLot := 0       
	   
   EndDo  
   
   //зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
   //Ё Imprime cabecalho...			                				  	 Ё
   //юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
   If !lAutost .AND. Li+3 > nQtdLin
       Cabec(cTitulo,cCabec1,cCabec2,cNomeProg,cTamanho,cMvNORM)
   Endif  
   
   @ Li,nColuna pSay STR0025+": "  + Space(94) + Transform(nTotSeq,"@E 999,999,999.99") //"Total do Sequencial de Auto-Gerado"
   Li ++ 
   @ Li,nColuna pSay replicate("-",nLimite)
   Li ++
   @ Li,nColuna pSay ""
   Li ++

   //зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
   //Ё Acumula valores                                                   Ё
   //юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
   nTotGer += nTotSeq
   nTotSeq := 0       

EndDo

//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Imprime cabecalho...			                				  Ё
//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
If !lAutost .AND. Li+4 > nQtdLin
    Cabec(cTitulo,cCabec1,cCabec2,cNomeProg,cTamanho,GetMv("MV_NORM"))
Endif  

If nTotGer > 0   
	@ Li,nColuna pSay ""
	Li ++ 
	@ Li,nColuna pSay replicate("=",nLimite)
	Li ++ 
	@ Li,nColuna pSay STR0026+": "  + Space(117) + Transform(nTotGer,"@E 999,999,999.99") //"Total Geral"
	Li ++ 
	@ Li,nColuna pSay replicate("=",nLimite)
	Li ++
Endif
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Fecha arquivo principal...                                               Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
TMP->(dbCloseArea())

//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Fim do Relat╒rio                                                         Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
Return

/*
ээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээ
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
╠╠иммммммммммяммммммммммкмммммммямммммммммммммммммммммкммммммяммммммммммммм╩╠╠
╠╠╨Programa  ЁAjustaSX1 ╨Autor  ЁThiago Machado Correa╨ Data Ё  25/08/04   ╨╠╠
╠╠лммммммммммьммммммммммймммммммомммммммммммммммммммммйммммммоммммммммммммм╧╠╠
╠╠╨Desc.     ЁCria o pergunte padrao                                       ╨╠╠
╠╠лммммммммммьммммммммммммммммммммммммммммммммммммммммммммммммммммммммммммм╧╠╠
╠╠╨Uso       Ё AP                                                          ╨╠╠
╠╠хммммммммммоммммммммммммммммммммммммммммммммммммммммммммммммммммммммммммм╪╠╠
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
ъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъ
*/
Static Function AjustaSX1()

Local aRegs	:=	{}
//Local cPerg	:=	'PLR982'

aadd(aRegs,{"PLR982","01","Operadora"   ,"","","mv_ch1","C", 4,0,0,"G","","mv_par01","","","","","","","","","","","","","","","","","","","","","","","","","B39",""})
aadd(aRegs,{"PLR982","02","Mes Inicial" ,"","","mv_ch2","C", 2,0,0,"G","","mv_par02","","","","","","","","","","","","","","","","","","","","","","","","","",""})
aadd(aRegs,{"PLR982","03","Ano Inicial" ,"","","mv_ch3","C", 4,0,0,"G","","mv_par03","","","","","","","","","","","","","","","","","","","","","","","","","",""})
aadd(aRegs,{"PLR982","04","Mes Final"   ,"","","mv_ch4","C", 2,0,0,"G","","mv_par04","","","","","","","","","","","","","","","","","","","","","","","","","",""})
aadd(aRegs,{"PLR982","05","Ano Final"   ,"","","mv_ch5","C", 4,0,0,"G","","mv_par05","","","","","","","","","","","","","","","","","","","","","","","","","",""})
aadd(aRegs,{"PLR982","06","Seq. Inicial","","","mv_ch6","C", 2,0,0,"G","","mv_par06","","","","","","","","","","","","","","","","","","","","","","","","","",""})
aadd(aRegs,{"PLR982","07","Seq. Final"  ,"","","mv_ch7","C", 2,0,0,"G","","mv_par07","","","","","","","","","","","","","","","","","","","","","","","","","",""})
aadd(aRegs,{"PLR982","08","Pgto Inicial","","","mv_ch8","C", 4,0,0,"G","","mv_par08","","","","","","","","","","","","","","","","","","","","","","","","","",""})
aadd(aRegs,{"PLR982","09","Pgto Final"  ,"","","mv_ch9","C", 4,0,0,"G","","mv_par09","","","","","","","","","","","","","","","","","","","","","","","","","",""})
aadd(aRegs,{"PLR982","10","Rda Inicial" ,"","","mv_cha","C", 6,0,0,"G","","mv_par10","","","","","","","","","","","","","","","","","","","","","","","","","BAU",""})
aadd(aRegs,{"PLR982","11","Rda Final"   ,"","","mv_chb","C", 6,0,0,"G","","mv_par11","","","","","","","","","","","","","","","","","","","","","","","","","BAU",""})
aadd(aRegs,{"PLR982","12","Listar"      ,"","","mv_chc","N", 1,0,0,"C","","mv_par12","Glosadas","","","","","Pagas","","","","","","","","","","","","","","","","","","","",""})

PlsVldPerg( aRegs )


Return
