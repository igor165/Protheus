#include "PROTHEUS.CH"
#include "PLSMGER.CH"
#include "TOPCONN.CH"

Static objCENFUNLGP := CENFUNLGP():New() 
Static lAutoSt := .F.

/*/
ээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээ
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
╠╠зддддддддддбдддддддддбдддддддбддддддддддддддддддддддддбддддддбдддддддддд©╠╠╠
╠╠ЁFuncao    Ё PLSR251 Ё Autor Ё Paulo Carnelossi       Ё Data Ё 20/08/03 Ё╠╠╠
╠╠цддддддддддедддддддддадддддддаддддддддддддддддддддддддаддддддадддддддддд╢╠╠╠
╠╠ЁDescricao Ё Despesas por Faixa Etaria/Idade                            Ё╠╠╠
╠╠цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢╠╠╠
╠╠ЁSintaxe   Ё PLSR251()                                                  Ё╠╠╠
╠╠цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢╠╠╠
╠╠Ё Uso      Ё Advanced Protheus                                          Ё╠╠╠
╠╠юддддддддддадддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды╠╠╠
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
ъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъ
/*/
Function PLSR251(lAuto)
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Dados dos parametros do relatorio...                                     Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
Local cCodInt
Local cCodEmpI
Local cCodEmpF
Local cMesBase
Local cAnoBase

Default lAuto := .F.

//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Define variaveis...                                                      Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
PRIVATE cNomeProg   := "PLSR251"
PRIVATE nCaracter   := 15
PRIVATE cTamanho    := "M"
PRIVATE cAlias      := "BD6"
PRIVATE cTitulo     := FunDesc() //"Despesas por Faixa EtАria"
PRIVATE cDesc1      := FunDesc() //"Despesas por Faixa EtАria"
PRIVATE cDesc2      := ""
PRIVATE cDesc3      := ""
PRIVATE cCabec1     := ""
PRIVATE cCabec2     := ""
PRIVATE cPerg       := "PLR251"
PRIVATE cRel        := "PLSR251"
PRIVATE nLi         := 01
PRIVATE m_pag       := 1
PRIVATE aReturn     := { "Zebrado", 1,"Administracao", 1, 1, 1, "",1 }
PRIVATE lAbortPrint := .F.                                                                       
PRIVATE aOrdens     := { "Por Faixa Etaria", "Por Idade"}
PRIVATE lDicion     := .F.
PRIVATE lCompres    := .F.
PRIVATE lCrystal    := .F.
PRIVATE lFiltro     := .F.

lAutoSt := lAuto

//-- LGPD ----------
if !objCENFUNLGP:getPermPessoais()
	objCENFUNLGP:msgNoPermissions()
	Return
Endif
//------------------

//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Chama SetPrint                                                           Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
if !lAuto
	cRel := SetPrint(cAlias,cRel,cPerg,@cTitulo,cDesc1,cDesc2,cDesc3,lDicion,aOrdens,lCompres,cTamanho,{},lFiltro,lCrystal)
endif
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Verifica se foi cancelada a operacao                                     Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
If !lAuto .AND. nLastKey  == 27
   Return
Endif
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Recebe parametros                                                        Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
Pergunte(cPerg,.F.)            
cCodInt  := mv_par01 ; cCodEmpI := mv_par02 ; cCodEmpF := mv_par03
cMesBase := mv_par04 ; cAnoBase := mv_par05

//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Configura Impressora                                                     Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
if !lAuto
	SetDefault(aReturn,cAlias)
endif
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Monta RptStatus...                                                       Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
if !lAuto
	MsAguarde( {|| ImpR251(cCodInt, cCodEmpI, cCodEmpF, cMesBase, cAnoBase) }  , "Imprimindo..." , "" , .T. )
else
	ImpR251(cCodInt, cCodEmpI, cCodEmpF, cMesBase, cAnoBase)
endif
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Fim da Rotina Principal...                                               Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
Return
/*/
ээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээ
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
╠╠зддддддддддбдддддддддбдддддддбддддддддддддддддддддддддбддддддбдддддддддд©╠╠╠
╠╠ЁFuncao    Ё ImpR251 Ё Autor Ё Paulo Carnelossi       Ё Data Ё 20/08/03 Ё╠╠╠
╠╠цддддддддддедддддддддадддддддаддддддддддддддддддддддддаддддддадддддддддд╢╠╠╠
╠╠ЁDescricao Ё Relatorio ...                                              Ё╠╠╠
╠╠юддддддддддадддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды╠╠╠
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
ъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъ
/*/
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Define nome da funcao                                                    Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
Static Function ImpR251(cCodInt, cCodEmpI, cCodEmpF, cMesBase, cAnoBase)
Local I
Local nQtdLin     := 53
Local nColuna     := 00
//Local nLimite     := 132

Local cLinha  := Space(00)
Local pMoeda  := "@E 9,999,999.99"
Local pQuant  := "@E 99999"
Local cSQL
//Local cInd

Local nIdade  := 0
Local nValor  := 0  
Local nVlrFx  := {{0,0,0,0,0,0,0},{0,0,0,0,0,0,0}}
Local nVlrIdade := {}

cTitulo += " ==> Operadora : " + cCodInt +" - "+ Padr(Posicione("BA0",1,xFilial("BA0")+cCodInt,"BA0_NOMINT"),45)
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Monta Consulta ao Servidor...                                            Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
cSQL := "SELECT (BA1.BA1_CODINT+BA1.BA1_CODEMP+BA1.BA1_MATRIC) MATRIC,BA1.BA1_DATNAS DATANAS "

cSQL += " FROM "+RetSQLName("BA1")+" BA1 " 

cSQL += " WHERE BA1.D_E_L_E_T_ <>  '*' "
cSQL += " AND BA1.BA1_CODINT = '"+cCodInt+"' AND BA1.BA1_CODEMP >= '"+cCodEmpI+"' AND"
cSQL += "  BA1.BA1_CODEMP <= '"+cCodEmpF+"' AND "
cSQL += "  BA1.BA1_DATINC <= '"+DTOS(LastDay(Ctod("01/" + mv_par04 + "/" + mv_par05)))+"' "

cSQL += "ORDER BY BA1.BA1_CODINT, BA1.BA1_CODEMP, BA1.BA1_MATRIC"

//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Monta area de trabalho com todos os procedimentos...                     Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
PlsQuery(cSQL,"TrbBA1")

//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Posicione no primeiro registro do arquivo de trabalho TrbTot e trbba1... Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
TrbBA1->(DbGoTop())
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Imprime cabecalho...                                                     Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
R251Cab()        

For I := 1 to 200
  aadd(nVlrIdade,{0,0})
Next 

While ! TrbBA1->(Eof())
      
      //здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
      //Ё Incrementa variaveis...                                            Ё
      //юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
      dData := Ctod(SubStr(TrbBA1->DATANAS,7,2) + "/" + SubStr(TrbBA1->DATANAS,5,2) + "/" + SubStr(TrbBA1->DATANAS,1,4))
      nIdade := Calc_Idade(dDataBase,dData)
      //здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
      //Ё Incrementa valores a variaveis...                                  Ё
      //юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
      If nIdade < 18 .And. nIdade >= 0 //faixa 1
            nVlrFx[1,1] := nVlrFx[1,1] + 1
      ElseIf  nIdade >=18 .And. nIdade <=29 //faixa 2
            nVlrFx[1,2] := nVlrFx[1,2] + 1
      ElseIf  nIdade >=30 .And. nIdade <=39 //faixa 3
            nVlrFx[1,3] := nVlrFx[1,3] + 1
      ElseIf  nIdade >=40 .And. nIdade <=49 //faixa 4
            nVlrFx[1,4] := nVlrFx[1,4] + 1
      ElseIf  nIdade >=50 .And. nIdade <=59 //faixa 5
            nVlrFx[1,5] := nVlrFx[1,5] + 1
      ElseIf  nIdade >=60 .And. nIdade <=69 //faixa 6
            nVlrFx[1,6] := nVlrFx[1,6] + 1
      ElseIf  nIdade >=70  .And. nIdade <=200  //faixa 7
            nVlrFx[1,7] := nVlrFx[1,7] + 1
      Else
           	FWLogMsg('WARN',, 'SIGAPLS', funName(), '', '01', "Erro Relatorio PLSR251.PRW - Matricula ("+TrbBA1->MATRIC+") Idade : "+str(nIdade,6) , 0, 0, {})
      Endif
      if nIdade <= 200 .And. nIdade >= 0 
        if nIdade == 0 
           nIdade := 1
        Endif   
        nVlrIdade[nIdade,1] := nVlrIdade[nIdade,1] + 1
      Endif   

      //здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
      //Ё Incrementa a regua...                                              Ё
      //юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
	if !lAutoSt
		If Valtype(TrbBA1->MATRIC) == "C"
		MsProcTxt("Processando... "+(TrbBA1->MATRIC))                                
		Else
		MsProcTxt("Processando... "+Str(TrbBA1->MATRIC))   	
		Endif
	endif
      //здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
      //Ё Acessa proximo registro...                                               Ё
      //юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
      TrbBA1->(DbSkip())
Enddo

TrbBA1->(DbCloseArea())
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Monta Consulta ao Servidor...                                            Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
cSQL := "SELECT (BD6.BD6_CODOPE||BD6.BD6_CODEMP||BD6.BD6_MATRIC||BD6.BD6_TIPREG) MATRIC, "
cSql += " BA1.BA1_DATNAS DATANAS ,SUM(BD6.BD6_VLRPAG-BD6.BD6_VLRGLO) VALOR "
cSql += " FROM "+RetSqlName("BD6")+" BD6 "

cSql += " INNER JOIN "+RetSqlName("BA1")+" BA1 "
cSql += " ON BD6.BD6_CODOPE = BA1.BA1_CODINT AND BD6.BD6_CODEMP = BA1.BA1_CODEMP "
cSql += " AND BD6.BD6_MATRIC = BA1.BA1_MATRIC AND BD6.BD6_TIPREG = BA1.BA1_TIPREG "

cSql += " WHERE BD6.BD6_MESINT = '"+cMesBase+"' AND BD6.BD6_CODOPE = '"+cCodInt+"'" 
cSql += " AND BD6.BD6_ANOINT = '"+cAnoBase+"' AND "

cSql += " BD6.BD6_CODEMP >= '"+cCodEmpI+"' AND BD6.BD6_CODEMP <= '"+cCodEmpF+"'"
cSql += " AND BA1.D_E_L_E_T_ <> '*' AND BD6.D_E_L_E_T_ <>  '*' "

cSql += " GROUP BY BD6.BD6_CODOPE, BD6.BD6_CODEMP, BD6.BD6_MATRIC, "
cSql += " BD6.BD6_TIPREG, BA1.BA1_DATNAS"

cSql += " ORDER BY BD6.BD6_CODOPE, BD6.BD6_CODEMP, BD6.BD6_MATRIC, "
cSql += " BD6.BD6_TIPREG, BA1.BA1_DATNAS"

cSql := ChangeQuery(cSql)
TCQUERY cSQL NEW ALIAS "TrbTot"

//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Posicione no primeiro registro do arquivo de trabalho TrbTot e trbba1... Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
TrbTot->(DbGoTop())                                                          
                
While ! TrbTot->(Eof())
      //здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
      //Ё Verifica se foi abortada a impressao...                            Ё
      //юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
      If !lAutoSt .AND. Interrupcao(lAbortPrint)
         Exit
      Endif

      //здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
      //Ё Incrementa variaveis...                                            Ё
      //юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
      dData := Ctod(SubStr(TrbTot->DATANAS,7,2) + "/" + SubStr(TrbTot->DATANAS,5,2) + "/" + SubStr(TrbTot->DATANAS,1,4))
      nIdade := Calc_Idade(dDataBase,dData)
      nValor := TrbTot->VALOR
      //здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
      //Ё Incrementa valores a variaveis...                                  Ё
      //юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
      If nIdade < 18 .And. nIdade >= 0 //faixa 1
            nVlrFx[2,1] := nVlrFx[2,1] + nValor
      ElseIf  nIdade >=18 .And. nIdade <=29 //faixa 2
            nVlrFx[2,2] := nVlrFx[2,2] + nValor
      ElseIf  nIdade >=30 .And. nIdade <=39 //faixa 3
            nVlrFx[2,3] := nVlrFx[2,3] + nValor
      ElseIf  nIdade >=40 .And. nIdade <=49 //faixa 4
            nVlrFx[2,4] := nVlrFx[2,4] + nValor
      ElseIf  nIdade >=50 .And. nIdade <=59 //faixa 5
            nVlrFx[2,5] := nVlrFx[2,5] + nValor
      ElseIf  nIdade >=60 .And. nIdade <=69 //faixa 6
            nVlrFx[2,6] := nVlrFx[2,6] + nValor
      ElseIf  nIdade >=70  .And. nIdade <=200  //faixa 7
            nVlrFx[2,7] := nVlrFx[2,7] + nValor
      Endif
      if nIdade <= 200 .And. nIdade >= 0 
         if nIdade == 0 
            nIdade := 1
         Endif   
         nVlrIdade[nIdade,2] := nVlrIdade[nIdade,2] + nValor
      Endif   

      //здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
      //Ё Incrementa a regua...                                              Ё
      //юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
	if !lAutoSt
		If Valtype(TrbTot->MATRIC) == "C"
		MsProcTxt("Processando... "+(TrbTot->MATRIC))                                
		Else
		MsProcTxt("Processando... "+Str(TrbTot->MATRIC))   	
		Endif
	endif
      //здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
      //Ё Acessa proximo registro...                                               Ё
      //юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
      TrbTot->(DbSkip())
Enddo

If     aReturn[8] == 1 // Por Faixa Etaria
	//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	//Ё Monta cabecalho p Plano Individual...                                    Ё
	//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
	cLinha := "Por Faixa Etaria:"
	nLi ++ 
	@ nLi, nColuna pSay cLinha
	nLi ++
	
	cLinha := "FAIXA ETARIA                  VALOR DESPESA"
	nLi ++
	@ nLi, nColuna pSay cLinha
	
	cLinha := Replicate("-",55)
	nLi ++ 
	@ nLi, nColuna pSay cLinha
	
	//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	//Ё Monta linha para impressao...                                      Ё
	//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
	cLinha := "0    a   17 anos" + Space(10)+Transform(nVlrFx[1,1],pQuant)+Transform(nVlrFx[2,1],pMoeda)
	nLi ++ 
	@ nLi, nColuna pSay cLinha
	
	cLinha := "18   a   29 anos" + Space(10)+Transform(nVlrFx[1,2],pQuant)+Transform(nVlrFx[2,2],pMoeda)
	nLi ++ 
	@ nLi, nColuna pSay cLinha
	
	cLinha := "30   a   39 anos" + Space(10)+Transform(nVlrFx[1,3],pQuant)+Transform(nVlrFx[2,3],pMoeda)
	nLi ++ 
	@ nLi, nColuna pSay cLinha
	
	cLinha := "40   a   49 anos" + Space(10)+Transform(nVlrFx[1,4],pQuant)+Transform(nVlrFx[2,4],pMoeda)
	nLi ++ 
	@ nLi, nColuna pSay cLinha
	
	cLinha := "50   a   59 anos" + Space(10)+Transform(nVlrFx[1,5],pQuant)+Transform(nVlrFx[2,5],pMoeda)
	nLi ++ 
	@ nLi, nColuna pSay cLinha
	
	cLinha := "60   a   69 anos" + Space(10)+Transform(nVlrFx[1,6],pQuant)+Transform(nVlrFx[2,6],pMoeda)
	nLi ++ 
	@ nLi, nColuna pSay cLinha
	
	cLinha := "Acima de 70 anos" + Space(10)+Transform(nVlrFx[1,7],pQuant)+Transform(nVlrFx[2,7],pMoeda)
	nLi ++ 
	@ nLi, nColuna pSay cLinha
	
	cLinha := Replicate("-",55)
	nLi ++ 
	@ nLi, nColuna pSay cLinha
	
	cLinha := "Total:" + Space(20)+Transform(nVlrFx[1,1]+nVlrFx[1,2]+nVlrFx[1,3]+nVlrFx[1,4]+nVlrFx[1,5]+nVlrFx[1,6]+nVlrFx[1,7],pQuant);
								   +Transform(nVlrFx[2,1]+nVlrFx[2,2]+nVlrFx[2,3]+nVlrFx[2,4]+nVlrFx[2,5]+nVlrFx[2,6]+nVlrFx[2,7],pMoeda) 
	nLi ++ 
	@ nLi, nColuna pSay cLinha
	nLi ++
	
Else

	nVlrTotal := 0
	nQtdTotal := 0
	//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	//Ё Monta cabecalho para Relatorio por Idade...                              Ё
	//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
	nLi ++
	cLinha := "Por Idade:"
	nLi ++ 
	nLi ++ ; @ nLi, nColuna pSay cLinha
	nLi ++

	cLinha := "Idade                         Valor Despesa "
	nLi ++ ; @ nLi, nColuna pSay cLinha

	cLinha := Replicate("-",55)
	nLi ++ ; @ nLi, nColuna pSay cLinha
	//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	//Ё Monta linha para impressao...                                      Ё
	//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
	For I := 1 to 200 
	   if nVlrIdade[I,2] > 0
	      cLinha :=  StrZero(I,2)+Space(24)+Transform(nVlrIdade[I,1],pQuant)+Transform(nVlrIdade[I,2],pMoeda)
	      nLi ++ ; @ nLi, nColuna pSay cLinha        
	      //здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	      //Ё Trata quantidade de linhas...                                            Ё
	      //юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
	      If nLi > nQtdLin
	         Roda(0,Space(10))
	         R251Cab()
	      Endif         
	      nVlrTotal += nVlrIdade[I,2]
	      nQtdTotal += nVlrIdade[I,1]
	   Endif   
	Next 

	cLinha := Replicate("-",55)
	nLi ++ ; @ nLi, nColuna pSay cLinha

	cLinha := "Total:" + Space(20)+ Transform(nQtdTotal,pQuant)+Transform(nVlrTotal,pMoeda) 
	nLi ++ ; @ nLi, nColuna pSay cLinha
	nLi ++

Endif

//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Trata quantidade de linhas...                                            Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
If nLi > nQtdLin
   R251Cab()
Endif         
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Fecha area de trabalho...                                                Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
TrbTot->(DbCloseArea())
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Imprime rodape...                                                  Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
if !lAutoSt
	Roda(0,Space(10))
endif
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Libera impressao                                                         Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
If !lAutoSt .AND. aReturn[5] == 1
    Set Printer To
    Ourspool(crel)
End
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Fim da impressao do relatorio...                                         Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
Return
/*/
ээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээ
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
╠╠зддддддддддбдддддддддбдддддддбддддддддддддддддддддддддбддддддбдддддддддд©╠╠╠
╠╠ЁFuncao    Ё R251Cab Ё Autor Ё Paulo Carnelossi       Ё Data Ё 20/08/03 Ё╠╠╠
╠╠цддддддддддедддддддддадддддддаддддддддддддддддддддддддаддддддадддддддддд╢╠╠╠
╠╠ЁDescricao Ё Cabecalho do relatorio.                                    Ё╠╠╠
╠╠юддддддддддадддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды╠╠╠
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
ъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъ
/*/
Static Function R251Cab()

nLi ++
if !lAutoSt
	nLi := cabec(cTitulo,cCabec1,cCabec2,cNomeProg,cTamanho,IIF(aReturn[4]==1,GetMv("MV_COMP"),GetMv("MV_NORM")))
endif
nLi ++                                     

Return

