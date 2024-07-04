#include "PROTHEUS.CH"
#include "PLSMGER.CH"
#include "TOPCONN.CH"

Static objCENFUNLGP := CENFUNLGP():New() 
Static lAutoSt := .F.

/*/
������������������������������������������������������������������������������
������������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ���
���Funcao    � PLSR251 � Autor � Paulo Carnelossi       � Data � 20/08/03 ����
�������������������������������������������������������������������������Ĵ���
���Descricao � Despesas por Faixa Etaria/Idade                            ����
�������������������������������������������������������������������������Ĵ���
���Sintaxe   � PLSR251()                                                  ����
�������������������������������������������������������������������������Ĵ���
��� Uso      � Advanced Protheus                                          ����
��������������������������������������������������������������������������ٱ��
������������������������������������������������������������������������������
������������������������������������������������������������������������������
/*/
Function PLSR251(lAuto)
//��������������������������������������������������������������������������Ŀ
//� Dados dos parametros do relatorio...                                     �
//����������������������������������������������������������������������������
Local cCodInt
Local cCodEmpI
Local cCodEmpF
Local cMesBase
Local cAnoBase

Default lAuto := .F.

//��������������������������������������������������������������������������Ŀ
//� Define variaveis...                                                      �
//����������������������������������������������������������������������������
PRIVATE cNomeProg   := "PLSR251"
PRIVATE nCaracter   := 15
PRIVATE cTamanho    := "M"
PRIVATE cAlias      := "BD6"
PRIVATE cTitulo     := FunDesc() //"Despesas por Faixa Et�ria"
PRIVATE cDesc1      := FunDesc() //"Despesas por Faixa Et�ria"
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

//��������������������������������������������������������������������������Ŀ
//� Chama SetPrint                                                           �
//����������������������������������������������������������������������������
if !lAuto
	cRel := SetPrint(cAlias,cRel,cPerg,@cTitulo,cDesc1,cDesc2,cDesc3,lDicion,aOrdens,lCompres,cTamanho,{},lFiltro,lCrystal)
endif
//��������������������������������������������������������������������������Ŀ
//� Verifica se foi cancelada a operacao                                     �
//����������������������������������������������������������������������������
If !lAuto .AND. nLastKey  == 27
   Return
Endif
//��������������������������������������������������������������������������Ŀ
//� Recebe parametros                                                        �
//����������������������������������������������������������������������������
Pergunte(cPerg,.F.)            
cCodInt  := mv_par01 ; cCodEmpI := mv_par02 ; cCodEmpF := mv_par03
cMesBase := mv_par04 ; cAnoBase := mv_par05

//��������������������������������������������������������������������������Ŀ
//� Configura Impressora                                                     �
//����������������������������������������������������������������������������
if !lAuto
	SetDefault(aReturn,cAlias)
endif
//��������������������������������������������������������������������������Ŀ
//� Monta RptStatus...                                                       �
//����������������������������������������������������������������������������
if !lAuto
	MsAguarde( {|| ImpR251(cCodInt, cCodEmpI, cCodEmpF, cMesBase, cAnoBase) }  , "Imprimindo..." , "" , .T. )
else
	ImpR251(cCodInt, cCodEmpI, cCodEmpF, cMesBase, cAnoBase)
endif
//��������������������������������������������������������������������������Ŀ
//� Fim da Rotina Principal...                                               �
//����������������������������������������������������������������������������
Return
/*/
������������������������������������������������������������������������������
������������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ���
���Funcao    � ImpR251 � Autor � Paulo Carnelossi       � Data � 20/08/03 ����
�������������������������������������������������������������������������Ĵ���
���Descricao � Relatorio ...                                              ����
��������������������������������������������������������������������������ٱ��
������������������������������������������������������������������������������
������������������������������������������������������������������������������
/*/
//��������������������������������������������������������������������������Ŀ
//� Define nome da funcao                                                    �
//����������������������������������������������������������������������������
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
//��������������������������������������������������������������������������Ŀ
//� Monta Consulta ao Servidor...                                            �
//����������������������������������������������������������������������������
cSQL := "SELECT (BA1.BA1_CODINT+BA1.BA1_CODEMP+BA1.BA1_MATRIC) MATRIC,BA1.BA1_DATNAS DATANAS "

cSQL += " FROM "+RetSQLName("BA1")+" BA1 " 

cSQL += " WHERE BA1.D_E_L_E_T_ <>  '*' "
cSQL += " AND BA1.BA1_CODINT = '"+cCodInt+"' AND BA1.BA1_CODEMP >= '"+cCodEmpI+"' AND"
cSQL += "  BA1.BA1_CODEMP <= '"+cCodEmpF+"' AND "
cSQL += "  BA1.BA1_DATINC <= '"+DTOS(LastDay(Ctod("01/" + mv_par04 + "/" + mv_par05)))+"' "

cSQL += "ORDER BY BA1.BA1_CODINT, BA1.BA1_CODEMP, BA1.BA1_MATRIC"

//��������������������������������������������������������������������������Ŀ
//� Monta area de trabalho com todos os procedimentos...                     �
//����������������������������������������������������������������������������
PlsQuery(cSQL,"TrbBA1")

//��������������������������������������������������������������������������Ŀ
//� Posicione no primeiro registro do arquivo de trabalho TrbTot e trbba1... �
//����������������������������������������������������������������������������
TrbBA1->(DbGoTop())
//��������������������������������������������������������������������������Ŀ
//� Imprime cabecalho...                                                     �
//����������������������������������������������������������������������������
R251Cab()        

For I := 1 to 200
  aadd(nVlrIdade,{0,0})
Next 

While ! TrbBA1->(Eof())
      
      //��������������������������������������������������������������������Ŀ
      //� Incrementa variaveis...                                            �
      //����������������������������������������������������������������������
      dData := Ctod(SubStr(TrbBA1->DATANAS,7,2) + "/" + SubStr(TrbBA1->DATANAS,5,2) + "/" + SubStr(TrbBA1->DATANAS,1,4))
      nIdade := Calc_Idade(dDataBase,dData)
      //��������������������������������������������������������������������Ŀ
      //� Incrementa valores a variaveis...                                  �
      //����������������������������������������������������������������������
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

      //��������������������������������������������������������������������Ŀ
      //� Incrementa a regua...                                              �
      //����������������������������������������������������������������������
	if !lAutoSt
		If Valtype(TrbBA1->MATRIC) == "C"
		MsProcTxt("Processando... "+(TrbBA1->MATRIC))                                
		Else
		MsProcTxt("Processando... "+Str(TrbBA1->MATRIC))   	
		Endif
	endif
      //��������������������������������������������������������������������������Ŀ
      //� Acessa proximo registro...                                               �
      //����������������������������������������������������������������������������
      TrbBA1->(DbSkip())
Enddo

TrbBA1->(DbCloseArea())
//��������������������������������������������������������������������������Ŀ
//� Monta Consulta ao Servidor...                                            �
//����������������������������������������������������������������������������
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

//��������������������������������������������������������������������������Ŀ
//� Posicione no primeiro registro do arquivo de trabalho TrbTot e trbba1... �
//����������������������������������������������������������������������������
TrbTot->(DbGoTop())                                                          
                
While ! TrbTot->(Eof())
      //��������������������������������������������������������������������Ŀ
      //� Verifica se foi abortada a impressao...                            �
      //����������������������������������������������������������������������
      If !lAutoSt .AND. Interrupcao(lAbortPrint)
         Exit
      Endif

      //��������������������������������������������������������������������Ŀ
      //� Incrementa variaveis...                                            �
      //����������������������������������������������������������������������
      dData := Ctod(SubStr(TrbTot->DATANAS,7,2) + "/" + SubStr(TrbTot->DATANAS,5,2) + "/" + SubStr(TrbTot->DATANAS,1,4))
      nIdade := Calc_Idade(dDataBase,dData)
      nValor := TrbTot->VALOR
      //��������������������������������������������������������������������Ŀ
      //� Incrementa valores a variaveis...                                  �
      //����������������������������������������������������������������������
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

      //��������������������������������������������������������������������Ŀ
      //� Incrementa a regua...                                              �
      //����������������������������������������������������������������������
	if !lAutoSt
		If Valtype(TrbTot->MATRIC) == "C"
		MsProcTxt("Processando... "+(TrbTot->MATRIC))                                
		Else
		MsProcTxt("Processando... "+Str(TrbTot->MATRIC))   	
		Endif
	endif
      //��������������������������������������������������������������������������Ŀ
      //� Acessa proximo registro...                                               �
      //����������������������������������������������������������������������������
      TrbTot->(DbSkip())
Enddo

If     aReturn[8] == 1 // Por Faixa Etaria
	//��������������������������������������������������������������������������Ŀ
	//� Monta cabecalho p Plano Individual...                                    �
	//����������������������������������������������������������������������������
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
	
	//��������������������������������������������������������������������Ŀ
	//� Monta linha para impressao...                                      �
	//����������������������������������������������������������������������
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
	//��������������������������������������������������������������������������Ŀ
	//� Monta cabecalho para Relatorio por Idade...                              �
	//����������������������������������������������������������������������������
	nLi ++
	cLinha := "Por Idade:"
	nLi ++ 
	nLi ++ ; @ nLi, nColuna pSay cLinha
	nLi ++

	cLinha := "Idade                         Valor Despesa "
	nLi ++ ; @ nLi, nColuna pSay cLinha

	cLinha := Replicate("-",55)
	nLi ++ ; @ nLi, nColuna pSay cLinha
	//��������������������������������������������������������������������Ŀ
	//� Monta linha para impressao...                                      �
	//����������������������������������������������������������������������
	For I := 1 to 200 
	   if nVlrIdade[I,2] > 0
	      cLinha :=  StrZero(I,2)+Space(24)+Transform(nVlrIdade[I,1],pQuant)+Transform(nVlrIdade[I,2],pMoeda)
	      nLi ++ ; @ nLi, nColuna pSay cLinha        
	      //��������������������������������������������������������������������������Ŀ
	      //� Trata quantidade de linhas...                                            �
	      //����������������������������������������������������������������������������
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

//��������������������������������������������������������������������������Ŀ
//� Trata quantidade de linhas...                                            �
//����������������������������������������������������������������������������
If nLi > nQtdLin
   R251Cab()
Endif         
//��������������������������������������������������������������������������Ŀ
//� Fecha area de trabalho...                                                �
//����������������������������������������������������������������������������
TrbTot->(DbCloseArea())
//��������������������������������������������������������������������Ŀ
//� Imprime rodape...                                                  �
//����������������������������������������������������������������������
if !lAutoSt
	Roda(0,Space(10))
endif
//��������������������������������������������������������������������������Ŀ
//� Libera impressao                                                         �
//����������������������������������������������������������������������������
If !lAutoSt .AND. aReturn[5] == 1
    Set Printer To
    Ourspool(crel)
End
//��������������������������������������������������������������������������Ŀ
//� Fim da impressao do relatorio...                                         �
//����������������������������������������������������������������������������
Return
/*/
������������������������������������������������������������������������������
������������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ���
���Funcao    � R251Cab � Autor � Paulo Carnelossi       � Data � 20/08/03 ����
�������������������������������������������������������������������������Ĵ���
���Descricao � Cabecalho do relatorio.                                    ����
��������������������������������������������������������������������������ٱ��
������������������������������������������������������������������������������
������������������������������������������������������������������������������
/*/
Static Function R251Cab()

nLi ++
if !lAutoSt
	nLi := cabec(cTitulo,cCabec1,cCabec2,cNomeProg,cTamanho,IIF(aReturn[4]==1,GetMv("MV_COMP"),GetMv("MV_NORM")))
endif
nLi ++                                     

Return

