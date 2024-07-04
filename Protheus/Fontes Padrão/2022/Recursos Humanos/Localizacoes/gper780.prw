#Include "RwMake.Ch"
#Include "PROTHEUS.Ch"
#Include "GPER780.Ch"

/*/
‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±⁄ƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒø±±
±±≥FunáÖo	 ≥ GPER780	≥ Autor ≥ Marcos Kato	        ≥ Data ≥ 08.09.08 ≥±±
±±√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥DescriáÖo ≥ Impressao Balanco Social		   			 		          ≥±±
±±√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥Retorno	 ≥ Nenhum       											  ≥±±
±±√ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥         ATUALIZACOES SOFRIDAS DESDE A CONSTRUÄAO INICIAL.             ≥±±
±±√ƒƒƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥Programador ≥ Data   ≥   BOPS    ≥  Motivo da Alteracao                ≥±±
±±√ƒƒƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¥±±
±±|Alex        |29/12/09|30658/2009 |AdaptaÁ„o para a Gest„o corporativa  |±± 
±±|            |        |           |respeitar o grupo de campos filiais. |±± 
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
/*/
Function GPER780()

Local cString		:= "RGN"
Private _nPag		:= 0
Private cPerg	 	:= STR0001//"GPM780"
Private nomeProg 	:= STR0002//"GPER780"
Private cTitulo 	:= STR0003//"Relatorio Anual Balanco Social" 
If !Pergunte(cPerg,.T.)
	Return
EndIf	
wnrel := STR0002//"GPER780" Nome Default do relatorio em Disco
MsgRun(STR0004,STR0005, {||CursorWait(),RGERBS() ,CursorArrow()})//Imprimindo dados gerados do Balanco Social #Aguarde...

Return

/*/
‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±⁄ƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒø±±
±±≥Funcao    ≥RGERBS ≥ Autor ≥ Marcos Kato              ≥ Data ≥ 12/07/07 ≥±±
±±≥ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥Descricao ≥Detalhe do Relatorio                                        ≥±±
±±√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥ Uso      ≥ Onsten                                                  	  ≥±±
±±¿ƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
/*/
Static Function RGERBS()
Private oPrint
Private nLin	 	:= 0
//±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±//
//Fontes de Impressao                                                         //
//±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±//
Private oArial14N	:= TFont():New("Arial",14,14,,.T.,,,,.F.,.F.)
Private oArial20N	:= TFont():New("Arial",20,20,,.T.,,,,.F.,.F.)
Private cStartPath	:= GetSrvProfString("Startpath","")
Private cFilEmp		:=MV_PAR01, cAnoEmp:=MV_PAR02
Private aListEmp:=ARRAY(50,10,13),aListEmp2:=Array(3,12,3)
Private aLPTrab:={},aLPNT:={}

oPrint:= TMSPrinter():New( ctitulo )
//±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±//
//Modo de Impressao                                                           //
//oPrint:SetLandscape() - Impressao Paisagem                                  //
//oPrint:SetPortrait()  - Impressao Retrato                                   //
//±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±//
oPrint:SetPortrait()
MsgRun(STR0006,STR0004, {||CursorWait(),IMPEMP(),CursorArrow()})//Gerando dados da Empresa #Aguarde...
MsgRun(STR0007,STR0004, {||CursorWait(),IMPFUN(),CursorArrow()})//Gerando dados do Empregado #Aguarde...
IMPGER()
oPrint:Preview()  				

Return
/*/
‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±⁄ƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒø±±
±±≥Funcao    ≥IMPEMP ≥ Autor ≥ Marcos Kato              ≥ Data ≥ 12/07/07 ≥±±
±±≥ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥Descricao ≥Detalhe do Relatorio                                        ≥±±
±±√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥ Uso      ≥ Onsten                                                  	  ≥±±
±±¿ƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
/*/
Static Function IMPEMP()
Local cQryEmp:="",cNomEmp1:= "",cNomEmp2:= "",cEndEmp1:= "",cEndEmp2:= "",cBaiEmp := ""
Local cMunEmp:="", cUFEmp  :="",cCepEmp := "",cTelEmp := "",cFaxEmp := "",cNatJur := ""
Local cEmailEmp:=""
Local cNumPCol:= ""
Local nNumCon:=0 , nNumAco :=0 ,nNumMad:=0 ,n002Jan:=0 ,n031Dez:=0 , nNMAno :=0  
Local nVlrAbr:=0 , nCusPes :=0 ,nAmoExe:=0 ,nProExe:=0 ,nCPFin :=0 , nImpRen:=0 ,nRLiExe:=0
//=========================================================================================
//================================EMPRESA================================================== 
//=========================================================================================
//=================================================================================================================================================
//PAGINA 01========================================================================================================================================
//=================================================================================================================================================
oPrint:Saybitmap(010,010,cStartPath+"BS01"+".bmp",2500,3400)  
nLin+=30   


DbSelectArea("SM0")
Dbseek(FwCodEmp("SM0")+"01")
//====================================================================================================
//Dados da Empresa - SIGAMAT
//====================================================================================================
cNomEmp1:=IIF(EMPTY(SM0->M0_NOMECOM),SM0->M0_NOME,SUBSTR(SM0->M0_NOMECOM,1,30))
cNomEmp2:=IIF(EMPTY(SM0->M0_NOMECOM)," ",SUBSTR(SM0->M0_NOMECOM,31,10))
cEndEmp1:=IIF(EMPTY(SM0->M0_ENDCOB) ,SUBSTR(SM0->M0_ENDENT,1,30),SUBSTR(SM0->M0_ENDCOB,1,30))
cEndEmp2:=IIF(EMPTY(SM0->M0_ENDCOB) ,SUBSTR(SM0->M0_ENDENT,31,30),SUBSTR(SM0->M0_ENDCOB,31,30))
cBaiEmp :=IIF(EMPTY(SM0->M0_ENDCOB) ,SM0->M0_BAIRENT,SM0->M0_BAIRCOB)
cMunEmp :=IIF(EMPTY(SM0->M0_CIDCOB) ,SM0->M0_CIDENT,SM0->M0_CIDCOB)
cUFEmp  :=IIF(EMPTY(SM0->M0_ESTCOB) ,SM0->M0_ESTENT,SM0->M0_ESTCOB)	
cCepEmp :=IIF(EMPTY(SM0->M0_CEPCOB) ,SM0->M0_CEPENT,SM0->M0_CEPCOB)
cTelEmp :=SM0->M0_FAX
cFaxEmp :=SM0->M0_TEL    
cNatJur :=" "
cNumPCol:=SM0->M0_CGC
//==============================================================================================================================================
//==================================Processando dados da Identificacao da Empresa do Balanco Social=============================================                                                                              
//==============================================================================================================================================
cQryEMP:=" SELECT RGN_ITEM,RGN_QTD1,RGN_VLR1,RGN_EMAIL"
cQryEMP+=" FROM "+RetSqlName("RGN")+" RGN "
cQryEMP+=" WHERE RGN_FILIAL = '"+cFilEmp+"' " 
cQryEMP+=" AND RGN_ANOBAS = '"+ALLTRIM(cAnoEmp)+"' " 
cQryEMP+=" AND RGN_PASTA = 'E' "
cQryEMP+=" AND D_E_L_E_T_='' "  

cQryEMP := ChangeQuery(cQryEMP)

If Select("TRBEMP")>0
	DbSelectArea("TRBEMP")
	TRBEMP->(DbCloseArea())
Endif

dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQryEMP),"TRBEMP",.F.,.T.)

//±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±//
//Seleciona a tabela temporaria e posicionar no topo do registro              //
//±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±//
dbSelectArea("TRBEMP")
TRBEMP->(dbGoTop())
If TRBEMP->(!Eof())
	cEmailEmp:=TRBEMP->RGN_EMAIL
	Do While TRBEMP->(!Eof())
		If Alltrim(TRBEMP->RGN_ITEM)=="5.1"//N Continente
			nNumCon:=TRBEMP->RGN_QTD1        
		Endif
		If Alltrim(TRBEMP->RGN_ITEM)=="5.2"//N Acores
			nNumAco:=TRBEMP->RGN_QTD1
		Endif
		If Alltrim(TRBEMP->RGN_ITEM)=="5.3"//N Madeira
			nNumMad:=TRBEMP->RGN_QTD1
		Endif
		If Alltrim(TRBEMP->RGN_ITEM)=="6.1"//Em 2 de Janeiro
			n002Jan:=TRBEMP->RGN_QTD1
		Endif
		If Alltrim(TRBEMP->RGN_ITEM)=="6.2"//Em 31 de Janeiro
			n031Dez:=TRBEMP->RGN_QTD1
		Endif
		If Alltrim(TRBEMP->RGN_ITEM)=="6.3"//Numero Medio durante o Ano
			nNMAno:=TRBEMP->RGN_QTD1
		Endif
		If Alltrim(TRBEMP->RGN_ITEM)=="8"  //Valor Acrescentado Bruto
			nVlrAbr:=TRBEMP->RGN_VLR1
		Endif
		If Alltrim(TRBEMP->RGN_ITEM)=="8.1"//Custos com o pessoal
			nCusPes:=TRBEMP->RGN_VLR1		
		Endif
		If Alltrim(TRBEMP->RGN_ITEM)=="8.2"//Amortizacao Exercicio
			nAmoExe:=TRBEMP->RGN_VLR1		
		Endif
		If Alltrim(TRBEMP->RGN_ITEM)=="8.3"//Provisoes do Exercicio
			nProExe:=TRBEMP->RGN_VLR1		
		Endif
		If Alltrim(TRBEMP->RGN_ITEM)=="8.4"//custos e perda financeira
			nCPFin:=TRBEMP->RGN_VLR1		
		Endif
		If Alltrim(TRBEMP->RGN_ITEM)=="8.5"//Imposto sobre o rendimento
			nImpRen:=TRBEMP->RGN_VLR1		
		Endif
		If Alltrim(TRBEMP->RGN_ITEM)=="8.6"//Resultado liquido do exercicio
			nRLiExe:=TRBEMP->RGN_VLR1		
        Endif

		TRBEMP->(DbSkip())
	End
Endif
nLin+=640
nCol:=450
oPrint:Say(nLin,nCol+1720  	  	,Substr(cAnoEmp,3,2) ,oArial20N)//Ano da Empresa
nLin+=240
oPrint:Say(nLin,nCol+20   	  	,cNomEmp1 ,oArial14N)//Nome da Empresa
nLin+=60
oPrint:Say(nLin,nCol+20   	  	,cNomEmp2 ,oArial14N)//Nome da Empresa - 2 Parte
nLin+=60
oPrint:Say(nLin,nCol+20   	  	,cEndEmp1 ,oArial14N)//Endereco(Morada) da Empresa
nLin+=80
oPrint:Say(nLin,nCol+20   	  	,cEndEmp2,oArial14N)//Endereco(Morada) da Empresa - 2 Parte
nLin+=60
oPrint:Say(nLin,nCol+20   	  	,cBaiEmp ,oArial14N)//Bairro(Freguesia)
nLin+=140
oPrint:Say(nLin,nCol+20   	  	,cCepEmp ,oArial14N)//Cep(Cod.Postal)
nLin+=80
oPrint:Say(nLin,nCol+20   	  	,cUFEmp  ,oArial14N)//Estado(Distrito)
oPrint:Say(nLin,nCol+1600 		,cTelEmp ,oArial14N)
nLin+=60
oPrint:Say(nLin,nCol+20   	  	,cMunEmp ,oArial14N)//Municipio(Concelho)
oPrint:Say(nLin,nCol+1600 		,cFaxEmp ,oArial14N)
nLin+=60
oPrint:Say(nLin,nCol+200  		,cEmailEmp,oArial14N)
nLin+=100                 
oPrint:Say(nLin,nCol+600  		,Space(14-Len(Alltrim(cNumPCol)))+Alltrim(cNumPCol) ,oArial14N)//Numeros  pessoas
nLin+=80               
oPrint:Say(nLin,nCol+440  		,"Atividade principal",oArial14N)
nLin+=80                 
oPrint:Say(nLin,nCol+20      	,"da empresa",oArial14N)
nLin+=200                 
oPrint:Say(nLin,nCol+200  ,Space(6-Len(Alltrim(Str(nNumCon))))+Transform(nNumCon,"@E 999999"),oArial14N)//N Continente
oPrint:Say(nLin,nCol+920  ,Space(6-Len(Alltrim(Str(nNumAco))))+Transform(nNumAco,"@E 999999"),oArial14N)//N Acores
oPrint:Say(nLin,nCol+1760 ,Space(6-Len(Alltrim(Str(nNumMad))))+Transform(nNumMad,"@E 999999"),oArial14N)//N Madeira
nLin+=240
oPrint:Say(nLin,nCol+260  ,Space(6-Len(Alltrim(Str(n002Jan))))+Transform(n002Jan,"@E 999999"),oArial14N)//Em 2 de Janeiro
oPrint:Say(nLin,nCol+1760 ,Transform(n031Dez,"@E 999,999,99"),oArial14N)//Em 31 de Janeiro
nLin+=100
oPrint:Say(nLin,nCol+560  ,Space(6-Len(Alltrim(Str(nNMAno))))+Transform(nNMAno ,"@E 999999"),oArial14N)//Numero Medio durante o Ano
nLin+=140
oPrint:Say(nLin,nCol+260  ,cNatJur                           ,oArial14N)//Natureza juridica
nLin+=60
oPrint:Say(nLin,nCol+800 ,Space(14-Len(Alltrim(Str(nVlrAbr))))+Transform(nVlrAbr,"@E 999,999,999.99"),oArial14N)//Valor Acrescentado Bruto
nLin+=70
oPrint:Say(nLin,nCol+800 ,Space(14-Len(Alltrim(Str(nCusPes))))+Transform(nCusPes,"@E 999,999,999.99"),oArial14N)//Custos com o pessoal
nLin+=70
oPrint:Say(nLin,nCol+800 ,Space(14-Len(Alltrim(Str(nAmoExe))))+Transform(nAmoExe,"@E 999,999,999.99"),oArial14N)//Amortizacao Exercicio
nLin+=70
oPrint:Say(nLin,nCol+800 ,Space(14-Len(Alltrim(Str(nProExe))))+Transform(nProExe,"@E 999,999,999.99"),oArial14N)//Provisoes do Exercicio
nLin+=70
oPrint:Say(nLin,nCol+800 ,Space(14-Len(Alltrim(Str(nCPFin))))+Transform(nCPFin ,"@E 999,999,999.99"),oArial14N)//custos e perda financeira
nLin+=70
oPrint:Say(nLin,nCol+800 ,Space(14-Len(Alltrim(Str(nImpRen))))+Transform(nImpRen,"@E 999,999,999.99"),oArial14N)//Imposto sobre o rendimento
nLin+=70
oPrint:Say(nLin,nCol+800 ,Space(14-Len(Alltrim(Str(nRLiExe))))+Transform(nRLiExe,"@E 999,999,999.99"),oArial14N)//Resultado liquido do exercicio
//±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±//
//Fecha a Tabela temporaria                                                   //
//±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±//
TRBEMP->(DbCloseArea())
oPrint:EndPage()
Return 
/*/
‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±⁄ƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒø±±
±±≥Funcao    ≥IMPFUN ≥ Autor ≥ Marcos Kato              ≥ Data ≥ 12/07/07 ≥±±
±±≥ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥Descricao ≥Detalhe do Relatorio                                        ≥±±
±±√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥ Uso      ≥ Onsten                                                  	  ≥±±
±±¿ƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
/*/
Static Function IMPFUN() 
Local cQryFUN:="",nSubI,nItem,nEt,nNivAnt,nEstran,nGraIns,nMotSai
Local nCnt:=0,nCnt1:=0,nCnt2:=0,nCnt3:=0,nPost:=0,nPNT:=0
Local aTotMSP:=Array(8),aTotMST:=Array(8)
//=========================================================================================
//================================EMPREGO================================================== 
//=========================================================================================
For nCnt1:=1 To 50
	For nCnt2:=1 To 10
		For nCnt3:=1 To 13
			aListEmp[nCnt1][nCnt2][nCnt3]:=0
		Next                            
	Next
Next
For nCnt1:=1 To 3
	For nCnt2:=1 To 12
		For nCnt3:=1 To 3      
		    If nCnt3==3
				aListEmp2[nCnt1][nCnt2][nCnt3]:=0
			Else
				aListEmp2[nCnt1][nCnt2][nCnt3]:=""
			Endif
		Next                            
	Next
Next            


cQryFUN:=" SELECT DISTINCT RGN_ITEM,RGN_SUBITE,RGN_DESCR,RGN_CODDOE,RGN_PNTHRS,RGN_QTD1,RGN_QTD2,RGN_VLR1,RGN_VLR2"
cQryFUN+=" FROM "+RetSqlName("RGN")+" RGN "
cQryFUN+=" WHERE RGN_FILIAL = '"+cFilEmp+"' " 
cQryFUN+=" AND RGN_ANOBAS = '"+ALLTRIM(cAnoEmp)+"' " 
cQryFUN+=" AND RGN_PASTA = 'F' "
cQryFUN+=" AND D_E_L_E_T_='' "  
cQryFUN+=" ORDER BY RGN_ITEM,RGN_SUBITE "

cQryFUN := ChangeQuery(cQryFUN)

If Select("TRBFUN")>0
	DbSelectArea("TRBFUN")
	TRBFUN->(DbCloseArea())
Endif

dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQryFUN),"TRBFUN",.F.,.T.)
If TRBFUN->(!Eof())
	Do While TRBFUN->(!Eof())	
		cItem:=Alltrim(TRBFUN->RGN_ITEM)
		Do While TRBFUN->(!Eof()) .And. cItem==Alltrim(TRBFUN->RGN_ITEM)    
			If Alltrim(cItem)=="1.03"//Estrutura Etaria
                nEtaria:=0
				If Alltrim(TRBFUN->RGN_SUBITE)=="0201"//Ate 15 Anos
	                nEtaria:=1
				ElseIf Alltrim(TRBFUN->RGN_SUBITE)=="0202"//De 16 a 17 Anos
                	nEtaria:=2				
				ElseIf Alltrim(TRBFUN->RGN_SUBITE)=="0203"//De 18 a 24 Anos
					nEtaria:=3
				ElseIf Alltrim(TRBFUN->RGN_SUBITE)=="0204"//De 25 a 29 Anos
					nEtaria:=4
				ElseIf Alltrim(TRBFUN->RGN_SUBITE)=="0205"//De 30 a 34 Anos
					nEtaria:=5
				ElseIf Alltrim(TRBFUN->RGN_SUBITE)=="0206"//De 35 a 39 Anos
					nEtaria:=6
				ElseIf Alltrim(TRBFUN->RGN_SUBITE)=="0207"//De 40 a 44 Anos
					nEtaria:=7
				ElseIf Alltrim(TRBFUN->RGN_SUBITE)=="0208"//De 45 a 49 Anos
					nEtaria:=8
				ElseIf Alltrim(TRBFUN->RGN_SUBITE)=="0209"//De 50 a 54 Anos
					nEtaria:=9
				ElseIf Alltrim(TRBFUN->RGN_SUBITE)=="0210"//De 55 a 59 Anos
					nEtaria:=10
				ElseIf Alltrim(TRBFUN->RGN_SUBITE)=="0211"//De 60 a 61 Anos
					nEtaria:=11
				ElseIf Alltrim(TRBFUN->RGN_SUBITE)=="0212"//De 62 a 64 Anos
					nEtaria:=12
				ElseIf Alltrim(TRBFUN->RGN_SUBITE)=="0213"//De 65 e mais Anos       
					nEtaria:=13
				Endif    
				aListEmp[7][1][nEtaria]:=TRBFUN->RGN_QTD1
				aListEmp[7][2][nEtaria]:=TRBFUN->RGN_QTD2
				aListEmp[7][3][nEtaria]:=TRBFUN->RGN_QTD1+TRBFUN->RGN_QTD2
			ElseIf Alltrim(cItem)=="1.04"//Nivel etario medio
			    //-----------------------------------------------------------------------------------------
			    //Nivel Etario Medio                                                                  
			    //-----------------------------------------------------------------------------------------
				aListEmp[8][1][1]:=TRBFUN->RGN_QTD1
			ElseIf Alltrim(cItem)=="1.05"//Nivel de Antiguidade
				If Alltrim(TRBFUN->RGN_SUBITE)=="0301"
                	nNivAnt:=1
				ElseIf Alltrim(TRBFUN->RGN_SUBITE)=="0302
					nNivAnt:=2//Mais 1 ate 2 Anos
				ElseIf Alltrim(TRBFUN->RGN_SUBITE)=="0303
					nNivAnt:=3//Mais 2 ate 5 Anos
				ElseIf Alltrim(TRBFUN->RGN_SUBITE)=="0304
					nNivAnt:=4//Mais 5 a 10 Anos
				ElseIf Alltrim(TRBFUN->RGN_SUBITE)=="0305
					nNivAnt:=5//De 10 a 15 Anos
				ElseIf Alltrim(TRBFUN->RGN_SUBITE)=="0306
				    nNivAnt:=6//Mais de 15 Anos
			   	Endif     
				aListEmp[9][1][nNivAnt]:=TRBFUN->RGN_QTD1
				aListEmp[9][2][nNivAnt]:=TRBFUN->RGN_QTD2
				aListEmp[9][3][nNivAnt]:=TRBFUN->RGN_QTD1+TRBFUN->RGN_QTD2
			ElseIf Alltrim(cItem)=="1.06"//Estrangeiros
				If Alltrim(TRBFUN->RGN_SUBITE)=="0401"
					nEstran:=1//De Paises da Uniao Europeia
				ElseIf Alltrim(TRBFUN->RGN_SUBITE)=="0402
					nEstran:=2//De Paises africanos de lingua oficial portuguesa
				ElseIf Alltrim(TRBFUN->RGN_SUBITE)=="0403
					nEstran:=3//Brasil
				ElseIf Alltrim(TRBFUN->RGN_SUBITE)=="0404
					nEstran:=4//Outros Paises
			   	Endif 
				aListEmp[10][1][nEstran]:=TRBFUN->RGN_QTD1
				aListEmp[10][2][nEstran]:=TRBFUN->RGN_QTD2
				aListEmp[10][3][nEstran]:=TRBFUN->RGN_QTD1+TRBFUN->RGN_QTD2
			ElseIf Alltrim(cItem)=="1.07"//Deficiente
				aListEmp[11][1][1]:=TRBFUN->RGN_QTD1
				aListEmp[11][2][1]:=TRBFUN->RGN_QTD2
				aListEmp[11][3][1]:=TRBFUN->RGN_QTD1+TRBFUN->RGN_QTD2
			ElseIf Alltrim(cItem)=="1.08"//Grau de Instrucao
				If Alltrim(TRBFUN->RGN_SUBITE)=="0501"
					nGraIns:=1//inferior ao 1 ciclo do ensino basico
				ElseIf Alltrim(TRBFUN->RGN_SUBITE)=="0502
					nGraIns:=2//1∞ ciclo do ensino b·sico
				ElseIf Alltrim(TRBFUN->RGN_SUBITE)=="0503
					nGraIns:=3//2∞ ciclo do ensino b·sico
				ElseIf Alltrim(TRBFUN->RGN_SUBITE)=="0504
					nGraIns:=4//3∞ ciclo do ensino b·sico
				ElseIf Alltrim(TRBFUN->RGN_SUBITE)=="0505
					nGraIns:=5//Ensino Secundario
				ElseIf Alltrim(TRBFUN->RGN_SUBITE)=="0506
					nGraIns:=6//Ensino Profissional
				ElseIf Alltrim(TRBFUN->RGN_SUBITE)=="0507
					nGraIns:=7//Ensino Supeior Politecnico
				ElseIf Alltrim(TRBFUN->RGN_SUBITE)=="0508
					nGraIns:=8//Ensino Supeior universitario
				ElseIf Alltrim(TRBFUN->RGN_SUBITE)=="0509
					nGraIns:=9//Outros					
				Endif	 
				aListEmp[12][1][nGraIns]:=TRBFUN->RGN_QTD1
				aListEmp[12][2][nGraIns]:=TRBFUN->RGN_QTD2
				aListEmp[12][3][nGraIns]:=TRBFUN->RGN_QTD1+TRBFUN->RGN_QTD2
			ElseIf Alltrim(TRBFUN->RGN_SUBITE)=="0101"//Dirigente
				nDirF:=TRBFUN->RGN_QTD2             
				nDirM:=TRBFUN->RGN_QTD1
			ElseIf Alltrim(TRBFUN->RGN_SUBITE)=="0102".Or.Alltrim(TRBFUN->RGN_SUBITE)=="0702"//Quadro Superior
				If Alltrim(TRBFUN->RGN_SUBITE)=="0102"
					nQSupF:=TRBFUN->RGN_QTD2       
					nQSupM:=TRBFUN->RGN_QTD1
				Else 
					nQSupM:=TRBFUN->RGN_QTD1
				Endif	
			ElseIf Alltrim(TRBFUN->RGN_SUBITE)=="0103".Or.Alltrim(TRBFUN->RGN_SUBITE)=="0703"//Quadro medio
				If Alltrim(TRBFUN->RGN_SUBITE)=="0103"			
					nQMedF:=TRBFUN->RGN_QTD2 
					nQMedM:=TRBFUN->RGN_QTD1
				Else 
					nQMedM:=TRBFUN->RGN_QTD1
				Endif	
			ElseIf Alltrim(TRBFUN->RGN_SUBITE)=="0104".Or.Alltrim(TRBFUN->RGN_SUBITE)=="0704"//Quadro Intermediario
				If Alltrim(TRBFUN->RGN_SUBITE)=="0104"			
					nQIntF:=RGN_QTD2 
					nQIntM:=TRBFUN->RGN_QTD1
				Else 
					nQIntM:=TRBFUN->RGN_QTD1
				Endif	
			ElseIf Alltrim(TRBFUN->RGN_SUBITE)=="0105".Or.Alltrim(TRBFUN->RGN_SUBITE)=="0705"//Profissionais altamente qualificados e qualificados
				If Alltrim(TRBFUN->RGN_SUBITE)=="0105"			
					nPAQF:=TRBFUN->RGN_QTD2 
					nPAQM:=TRBFUN->RGN_QTD1
				Else 
					nPAQM:=TRBFUN->RGN_QTD1
				Endif	
			ElseIf Alltrim(TRBFUN->RGN_SUBITE)=="0106".Or.Alltrim(TRBFUN->RGN_SUBITE)=="0706"//Profissionais Semiqualificados
				If Alltrim(TRBFUN->RGN_SUBITE)=="0106"			
					nPSQF:=TRBFUN->RGN_QTD2 
					nPSQM:=TRBFUN->RGN_QTD1
				Else 
					nPSQM:=TRBFUN->RGN_QTD1
				Endif	
			ElseIf Alltrim(TRBFUN->RGN_SUBITE)=="0107".Or.Alltrim(TRBFUN->RGN_SUBITE)=="0707"//Profissionais nao qualificados
				If Alltrim(TRBFUN->RGN_SUBITE)=="0107"			
					nPNQF:=TRBFUN->RGN_QTD2        
					nPNQM:=TRBFUN->RGN_QTD1
				Else 
					nPNQM:=TRBFUN->RGN_QTD1
				Endif	
			ElseIf Alltrim(TRBFUN->RGN_SUBITE)=="0108".Or.Alltrim(TRBFUN->RGN_SUBITE)=="0708"//Praticantes\Aprendizes
				If Alltrim(TRBFUN->RGN_SUBITE)=="0108"			
					nPApF:=TRBFUN->RGN_QTD2 
					nPApM:=TRBFUN->RGN_QTD1
				Else 
					nPApM:=TRBFUN->RGN_QTD1
				Endif	
			ElseIf Alltrim(cItem)=="1.14"//Posto de trabalho nao ocupado 
				If !Empty(TRBFUN->RGN_DESCR)     
					nPost++  				
					aListEmp2[1][nPost][1]:=TRBFUN->RGN_DESCR
					aListEmp2[1][nPost][3]:=TRBFUN->RGN_QTD1
				Endif
			ElseIf Alltrim(cItem)=="1.17.1"//PNT-PERIODO NORMAL DE TRABALHO
				nPNT++      
				aListEmp2[2][nPNT][1]:=TRBFUN->RGN_PNTHRS
				aListEmp2[2][nPNT][3]:=TRBFUN->RGN_QTD1
			ElseIf Alltrim(cItem)=="1.17.2"//Tipos de horario predominantes durante o ano 
				If Alltrim(TRBFUN->RGN_SUBITE)=="0001"//Horario Normal Fixo
					aListEmp[30][1][1]:=TRBFUN->RGN_QTD1
				ElseIf Alltrim(TRBFUN->RGN_SUBITE)=="0002"//Horario Flexivel        
					aListEmp[30][1][2]:=TRBFUN->RGN_QTD1
				ElseIf Alltrim(TRBFUN->RGN_SUBITE)=="0003"//Horario de Turno(Fixo e/ou rotativo)
					aListEmp[30][1][3]:=TRBFUN->RGN_QTD1
				ElseIf Alltrim(TRBFUN->RGN_SUBITE)=="0004"//Horario irregular e/ou movel
					aListEmp[30][1][4]:=TRBFUN->RGN_QTD1
				ElseIf Alltrim(TRBFUN->RGN_SUBITE)=="0005"//Horario reduzido
					aListEmp[30][1][5]:=TRBFUN->RGN_QTD1
				ElseIf Alltrim(TRBFUN->RGN_SUBITE)=="0006"//insencao de horario     
					aListEmp[30][1][6]:=TRBFUN->RGN_QTD1
				Endif 
			ElseIf Alltrim(cItem)=="1.17.3"//Potencia Maxima Anual(horas trabalhaveis)            
				aListEmp[31][1][1]:=TRBFUN->RGN_QTD1
			ElseIf Alltrim(cItem)=="1.17.4"//Total de Horas Efectivamente Trabalhadas
				aListEmp[32][1][1]:=TRBFUN->RGN_QTD1
			ElseIf Alltrim(cItem)=="1.17.5.1"//Em Dias uteis
				aListEmp[33][1][1]:=TRBFUN->RGN_QTD1
				aListEmp[33][1][2]:=TRBFUN->RGN_QTD2
				aListEmp[33][1][3]:=TRBFUN->RGN_QTD1+TRBFUN->RGN_QTD2
			ElseIf Alltrim(cItem)=="1.17.5.2"//Em dia de descanso complementar e feriado
				aListEmp[34][1][1]:=TRBFUN->RGN_QTD1
				aListEmp[34][1][2]:=TRBFUN->RGN_QTD2
				aListEmp[34][1][3]:=TRBFUN->RGN_QTD1+TRBFUN->RGN_QTD2
			ElseIf Alltrim(cItem)=="1.17.5.3"//Em dia de descanso obrigatorio 
				aListEmp[35][1][1]:=TRBFUN->RGN_QTD1
				aListEmp[35][1][2]:=TRBFUN->RGN_QTD2
				aListEmp[35][1][3]:=TRBFUN->RGN_QTD1+TRBFUN->RGN_QTD2
			ElseIf Alltrim(cItem)=="1.18.1"//Por acidente de trabalho (Ausencias ao Trabalho)
				aListEmp[36][1][1]:=TRBFUN->RGN_QTD1
				aListEmp[36][1][2]:=TRBFUN->RGN_QTD2
				aListEmp[36][1][3]:=TRBFUN->RGN_QTD1+TRBFUN->RGN_QTD2
				aListEmp[36][2][1]:=TRBFUN->RGN_VLR1
				aListEmp[36][2][2]:=TRBFUN->RGN_VLR2
				aListEmp[36][2][3]:=TRBFUN->RGN_VLR1+TRBFUN->RGN_VLR2
			ElseIf Alltrim(cItem)=="1.18.2"//Por Doenca(Total)  
				aListEmp[37][1][1]:=TRBFUN->RGN_QTD1
				aListEmp[37][1][2]:=TRBFUN->RGN_QTD2
				aListEmp[37][1][3]:=TRBFUN->RGN_QTD1+TRBFUN->RGN_QTD2
				aListEmp[37][2][1]:=TRBFUN->RGN_VLR1
				aListEmp[37][2][2]:=TRBFUN->RGN_VLR2
				aListEmp[37][2][3]:=TRBFUN->RGN_VLR1+TRBFUN->RGN_VLR2
			ElseIf Alltrim(cItem)=="1.18.2.1"//Por Doencas Profissionais 
				aListEmp[38][1][1]:=TRBFUN->RGN_QTD1
				aListEmp[38][1][2]:=TRBFUN->RGN_QTD2
				aListEmp[38][1][3]:=TRBFUN->RGN_QTD1+TRBFUN->RGN_QTD2
				aListEmp[38][2][1]:=TRBFUN->RGN_VLR1
				aListEmp[38][2][2]:=TRBFUN->RGN_VLR2
				aListEmp[38][2][3]:=TRBFUN->RGN_VLR1+TRBFUN->RGN_VLR2
			ElseIf Alltrim(cItem)=="1.18.3"//Por suspensoes disciplinares   
				aListEmp[39][1][1]:=TRBFUN->RGN_QTD1
				aListEmp[39][1][2]:=TRBFUN->RGN_QTD2
				aListEmp[39][1][3]:=TRBFUN->RGN_QTD1+TRBFUN->RGN_QTD2
				aListEmp[39][2][1]:=TRBFUN->RGN_VLR1
				aListEmp[39][2][2]:=TRBFUN->RGN_VLR2
				aListEmp[39][2][3]:=TRBFUN->RGN_VLR1+TRBFUN->RGN_VLR2
			ElseIf Alltrim(cItem)=="1.18.4"//Por assistencia inadiavel   
				aListEmp[40][1][1]:=TRBFUN->RGN_QTD1
				aListEmp[40][1][2]:=TRBFUN->RGN_QTD2
				aListEmp[40][1][3]:=TRBFUN->RGN_QTD1+TRBFUN->RGN_QTD2
				aListEmp[40][2][1]:=TRBFUN->RGN_VLR1
				aListEmp[40][2][2]:=TRBFUN->RGN_VLR2
				aListEmp[40][2][3]:=TRBFUN->RGN_VLR1+TRBFUN->RGN_VLR2
			ElseIf Alltrim(cItem)=="1.18.5"//Por Maternidade/Paternidade    
				aListEmp[41][1][1]:=TRBFUN->RGN_QTD1
				aListEmp[41][1][2]:=TRBFUN->RGN_QTD2
				aListEmp[41][1][3]:=TRBFUN->RGN_QTD1+TRBFUN->RGN_QTD2
				aListEmp[41][2][1]:=TRBFUN->RGN_VLR1
				aListEmp[41][2][2]:=TRBFUN->RGN_VLR2
				aListEmp[41][2][3]:=TRBFUN->RGN_VLR1+TRBFUN->RGN_VLR2
			ElseIf Alltrim(cItem)=="1.18.6"//Por outras causas  
				aListEmp[42][1][1]:=TRBFUN->RGN_QTD1
				aListEmp[42][1][2]:=TRBFUN->RGN_QTD2
				aListEmp[42][1][3]:=TRBFUN->RGN_QTD1+TRBFUN->RGN_QTD2
				aListEmp[42][2][1]:=TRBFUN->RGN_VLR1
				aListEmp[42][2][2]:=TRBFUN->RGN_VLR2
				aListEmp[42][2][3]:=TRBFUN->RGN_VLR1+TRBFUN->RGN_VLR2
			ElseIf Alltrim(cItem)=="1.18.7"//Total de Ausencias(Remuneradas e nao remuneradas)
				aListEmp[43][1][1]:=TRBFUN->RGN_QTD1
				aListEmp[43][1][2]:=TRBFUN->RGN_QTD2
				aListEmp[43][1][3]:=TRBFUN->RGN_QTD1+TRBFUN->RGN_QTD2
				aListEmp[43][2][1]:=TRBFUN->RGN_VLR1
				aListEmp[43][2][2]:=TRBFUN->RGN_VLR2
				aListEmp[43][2][3]:=TRBFUN->RGN_VLR1+TRBFUN->RGN_VLR2
			ElseIf Alltrim(cItem)=="1.18.7.1"//Por Ausencia Remuneradas				
				aListEmp[44][1][1]:=TRBFUN->RGN_QTD1
				aListEmp[44][1][2]:=TRBFUN->RGN_QTD2
				aListEmp[44][1][3]:=TRBFUN->RGN_QTD1+TRBFUN->RGN_QTD2
				aListEmp[44][2][1]:=TRBFUN->RGN_VLR1
				aListEmp[44][2][2]:=TRBFUN->RGN_VLR2
				aListEmp[44][2][3]:=TRBFUN->RGN_VLR1+TRBFUN->RGN_VLR2
			ElseIf Alltrim(cItem)=="1.18.7.2"//Por Ausencia nao Remuneradas
				aListEmp[45][1][1]:=TRBFUN->RGN_QTD1
				aListEmp[45][1][2]:=TRBFUN->RGN_QTD2
				aListEmp[45][1][3]:=TRBFUN->RGN_QTD1+TRBFUN->RGN_QTD2
				aListEmp[45][2][1]:=TRBFUN->RGN_VLR1
				aListEmp[45][2][2]:=TRBFUN->RGN_VLR2
				aListEmp[45][2][3]:=TRBFUN->RGN_VLR1+TRBFUN->RGN_VLR2
			ElseIf Alltrim(cItem)=="1.19.1"//Por formacao profissional
				aListEmp[46][1][1]:=TRBFUN->RGN_QTD1
				aListEmp[46][1][2]:=TRBFUN->RGN_QTD2
				aListEmp[46][1][3]:=TRBFUN->RGN_QTD1+TRBFUN->RGN_QTD2
			ElseIf Alltrim(cItem)=="1.19.2"//Por reducao legal da atividade
				aListEmp[47][1][1]:=TRBFUN->RGN_QTD1
				aListEmp[47][1][2]:=TRBFUN->RGN_QTD2
				aListEmp[47][1][3]:=TRBFUN->RGN_QTD1+TRBFUN->RGN_QTD2
			ElseIf Alltrim(cItem)=="1.19.3"//Por desemprego interno
				aListEmp[48][1][1]:=TRBFUN->RGN_QTD1
				aListEmp[48][1][2]:=TRBFUN->RGN_QTD2
				aListEmp[48][1][3]:=TRBFUN->RGN_QTD1+TRBFUN->RGN_QTD2
			ElseIf Alltrim(cItem)=="1.19.4"//Por Descanso suplementar 
				aListEmp[49][1][1]:=TRBFUN->RGN_QTD1
				aListEmp[49][1][2]:=TRBFUN->RGN_QTD2
				aListEmp[49][1][3]:=TRBFUN->RGN_QTD1+TRBFUN->RGN_QTD2
			ElseIf Alltrim(cItem)=="1.19.5"//Por Greves/paralizacoes
				aListEmp[50][1][1]:=TRBFUN->RGN_QTD1
				aListEmp[50][1][2]:=TRBFUN->RGN_QTD2
				aListEmp[50][1][3]:=TRBFUN->RGN_QTD1+TRBFUN->RGN_QTD2
			Endif
			TRBFUN->(DbSkip())
		End              
		//******************************************************************************************                       
		//Reparticao de Efetivos		                                                            
		//******************************************************************************************                       
		If Alltrim(cItem)=="1.01" .Or. Alltrim(cItem)=="1.01.1" .Or. Alltrim(cItem)=="1.01.2" ;
		.Or. Alltrim(cItem)=="1.01.3" .Or. Alltrim(cItem)=="1.01.4" .Or. Alltrim(cItem)=="1.02"  
			If Alltrim(cItem)=="1.01"       
				nItem:=1//Pessoas ao Servico em 31 de Dezembro
			ElseIf Alltrim(cItem)=="1.01.1"		
			    nItem:=2//Com Contrato Permanente
			ElseIf Alltrim(cItem)=="1.01.2"                                                                                                                  
			    nItem:=3//Com Contrato a Termo Certo
			ElseIf Alltrim(cItem)=="1.01.3"		
			    nItem:=4//Com Contrato a Termo Incerto
			ElseIf Alltrim(cItem)=="1.01.4"				
			    nItem:=5//Outros
			ElseIf Alltrim(cItem)=="1.02"
			    nItem:=6//Numero medio de pessoas durante o ano
			Endif
			nTotM:=nDirM+nQSupM+nQMedM+nQIntM+nPAQM+nPSQM+nPNQM+nPApM
			nTotF:=nDirF+nQSupF+nQMedM+nQIntF+nPAQF+nPSQF+nPNQF+nPApF
			//Masculino
			aListEmp[nItem][1][1]:=nDirM
			aListEmp[nItem][1][2]:=nQSupM
			aListEmp[nItem][1][3]:=nQMedM
			aListEmp[nItem][1][4]:=nQIntM
			aListEmp[nItem][1][5]:=nPAQM
			aListEmp[nItem][1][6]:=nPSQM
			aListEmp[nItem][1][7]:=nPNQM
			aListEmp[nItem][1][8]:=nPApM
			aListEmp[nItem][1][9]:=nTotM 
			//Feminino
			aListEmp[nItem][2][1]:=nDirF
			aListEmp[nItem][2][2]:=nQSupF
			aListEmp[nItem][2][3]:=nQMedF
			aListEmp[nItem][2][4]:=nQIntF
			aListEmp[nItem][2][5]:=nPAQF
			aListEmp[nItem][2][6]:=nPSQF
			aListEmp[nItem][2][7]:=nPNQF
			aListEmp[nItem][2][8]:=nPApF
			aListEmp[nItem][2][9]:=nTotF
			//Total
			aListEmp[nItem][3][1]:=nDirM+nDirF
			aListEmp[nItem][3][2]:=nQSupM+nQSupF
			aListEmp[nItem][3][3]:=nQMedM+nQMedF
			aListEmp[nItem][3][4]:=nQIntM+nQIntF
			aListEmp[nItem][3][5]:=nPAQM+nPAQF
			aListEmp[nItem][3][6]:=nPSQM+nPSQF
			aListEmp[nItem][3][7]:=nPNQM+nPNQF
			aListEmp[nItem][3][8]:=nPApM+nPApF
			aListEmp[nItem][3][9]:=nTotM+nTotF
        Endif
	 	//******************************************************************************************                       
        //Contratatados a Termo e Movimentos de Saida
		//******************************************************************************************                       
		If Alltrim(cItem)=="1.09.1" .Or. Alltrim(cItem)=="1.09.2" .Or. Alltrim(cItem)=="1.09.3" ;
		.Or. Alltrim(cItem)=="1.09.4" .Or. Alltrim(cItem)=="1.09.5" .Or. Alltrim(cItem)=="1.10.1" ;  
		.Or. Alltrim(cItem)=="1.10.2" .Or. Alltrim(cItem)=="1.10.3" .Or. Alltrim(cItem)=="1.15.1" ;  
		.Or. Alltrim(cItem)=="1.15.2" .Or. Alltrim(cItem)=="1.15.3" .Or. Alltrim(cItem)=="1.15.4" ;
		.Or. Alltrim(cItem)=="1.16" 
			If Alltrim(cItem)=="1.09.1"
			    nItem:=13//Contratados a termo certo(Contratados a Termo)
			ElseIf Alltrim(cItem)=="1.09.2"
			    nItem:=14//Contratados a termo incerto(Contratados a Termo)
			ElseIf Alltrim(cItem)=="1.09.3"
			    nItem:=15//Contratados a termo que passaram ao quadro permanente(Contratados a Termo)		
			ElseIf Alltrim(cItem)=="1.09.4"
			    nItem:=16//Contratados a termo que transitaram do ano anterior(Contratados a Termo)
			ElseIf Alltrim(cItem)=="1.09.5"
			    nItem:=17//Numero medio anual de contratados a termo(Contratados a Termo)		
			ElseIf Alltrim(cItem)=="1.10.1"
			    nItem:=18//Saida de pessoal com contrato permanente(Movimentos de Saida)		
			ElseIf Alltrim(cItem)=="1.10.2"
			    nItem:=19//Saida de pessoal com contrato a termo(Movimentos de Saida)
			ElseIf Alltrim(cItem)=="1.10.3"
			    nItem:=20//Saida de Outros Trabalhadores(Movimentos de Saida)		
			ElseIf Alltrim(cItem)=="1.15.1"
			    nItem:=25//Antiguidade(Promocoes)				
			ElseIf Alltrim(cItem)=="1.15.2"
			    nItem:=26//Merito(Promocoes)		
			ElseIf Alltrim(cItem)=="1.15.3"
			    nItem:=27//Outras(Promocoes)		
			ElseIf Alltrim(cItem)=="1.15.4"
			    nItem:=28//Total(Promocoes)		
			ElseIf Alltrim(cItem)=="1.16"
			    nItem:=29//Numero de Trabalhadores(Reconversoes/Reclassificacoes)		
			Endif
			nTotM:=nQSupM+nQMedM+nQIntM+nPAQM+nPSQM+nPNQM+nPApM
			nTotF:=nQSupF+nQMedM+nQIntF+nPAQF+nPSQF+nPNQF+nPApF
			//Masculino
			aListEmp[nItem][1][1]:=nQSupM
			aListEmp[nItem][1][2]:=nQMedM
			aListEmp[nItem][1][3]:=nQIntM
			aListEmp[nItem][1][4]:=nPAQM
			aListEmp[nItem][1][5]:=nPSQM
			aListEmp[nItem][1][6]:=nPNQM
			aListEmp[nItem][1][7]:=nPApM
			aListEmp[nItem][1][8]:=nTotM 
			//Feminino
			aListEmp[nItem][2][1]:=nQSupF
			aListEmp[nItem][2][2]:=nQMedF
			aListEmp[nItem][2][3]:=nQIntF
			aListEmp[nItem][2][4]:=nPAQF
			aListEmp[nItem][2][5]:=nPSQF
			aListEmp[nItem][2][6]:=nPNQF
			aListEmp[nItem][2][7]:=nPApF
			aListEmp[nItem][2][8]:=nTotF
			//Total
			aListEmp[nItem][3][1]:=nQSupM+nQSupF
			aListEmp[nItem][3][2]:=nQMedM+nQMedF
			aListEmp[nItem][3][3]:=nQIntM+nQIntF
			aListEmp[nItem][3][4]:=nPAQM+nPAQF
			aListEmp[nItem][3][5]:=nPSQM+nPSQF
			aListEmp[nItem][3][6]:=nPNQM+nPNQF
			aListEmp[nItem][3][7]:=nPApM+nPApF
			aListEmp[nItem][3][8]:=nTotM+nTotF
		Endif	
		//******************************************************************************************                       
		If Substr(Alltrim(cItem),1,4)=="1.11"//contrato permanente	
			If Alltrim(cItem)=="1.11.01"//iniciativa do trabalhador
				nMotsai:=1
			ElseIf Alltrim(cItem)=="1.11.02"//Mutuo Acordo		
				nMotsai:=2
			ElseIf Alltrim(cItem)=="1.11.03"//iniciativa da empresa
				nMotsai:=3
			ElseIf Alltrim(cItem)=="1.11.04"//Despedimento coletivo
				nMotsai:=4
			ElseIf Alltrim(cItem)=="1.11.05"//Despedimento
				nMotsai:=5
			ElseIf Alltrim(cItem)=="1.11.06"//Reforma invalidez
				nMotsai:=6
			ElseIf Alltrim(cItem)=="1.11.07"//Reforma por Velhice
				nMotsai:=7
			ElseIf Alltrim(cItem)=="1.11.08"//Reforma Antecipada
				nMotsai:=8
			ElseIf Alltrim(cItem)=="1.11.09"//pre-Reforma		
				nMotsai:=9
			ElseIf Alltrim(cItem)=="1.11.10"//Falecimento
				nMotsai:=10
			Endif
			nTotM:=nQSupM+nQMedM+nQIntM+nPAQM+nPSQM+nPNQM+nPApM
			aListEmp[21][nMotSAi][1]:=nQSupM
			aListEmp[21][nMotSAi][2]:=nQMedM
			aListEmp[21][nMotSAi][3]:=nQIntM	
			aListEmp[21][nMotSAi][4]:=nPAQM	
			aListEmp[21][nMotSAi][5]:=nPSQM
			aListEmp[21][nMotSAi][6]:=nPNQM	
			aListEmp[21][nMotSAi][7]:=nPApM
			aListEmp[21][nMotSAi][8]:=nTotM																						
		Endif                                                                     
		If Substr(Alltrim(cItem),1,4)=="1.12"//Contrato a Termo
			If Alltrim(cItem)=="1.12.01"//Por cessacao do contrato a termo incerto
				nMotsai:=1
			ElseIf Alltrim(cItem)=="1.12.02"//Por cessacao do contrato a termo incerto
				nMotsai:=2
			ElseIf Alltrim(cItem)=="1.12.03"//Por antecipacao da cessacao do contrato a termo certo
				nMotsai:=3
			ElseIf Alltrim(cItem)=="1.12.04"//Por antecipacao da cessacao do contrato a termo Incerto
				nMotsai:=4
		    Endif
			nTotM:=nQSupM+nQMedM+nQIntM+nPAQM+nPSQM+nPNQM+nPApM
			aListEmp[22][nMotSAi][1]:=nQSupM
			aListEmp[22][nMotSAi][2]:=nQMedM
			aListEmp[22][nMotSAi][3]:=nQIntM	
			aListEmp[22][nMotSAi][4]:=nPAQM	
			aListEmp[22][nMotSAi][5]:=nPSQM
			aListEmp[22][nMotSAi][6]:=nPNQM	
			aListEmp[22][nMotSAi][7]:=nPApM
			aListEmp[22][nMotSAi][8]:=nTotM																						
		Endif	
		If Alltrim(cItem)=="1.13"//Situacoes especiais de saida por impedimento prolongado
			nTotM:=nQSupM+nQMedM+nQIntM+nPAQM+nPSQM+nPNQM+nPApM
			aListEmp[23][1][2]:=nQSupM
			aListEmp[23][1][3]:=nQMedM
			aListEmp[23][1][4]:=nQIntM	
			aListEmp[23][1][5]:=nPAQM	
			aListEmp[23][1][6]:=nPSQM
			aListEmp[23][1][7]:=nPNQM	
			aListEmp[23][1][8]:=nPApM
			aListEmp[23][1][9]:=nTotM																		
		Endif	     
		nDirM:=0
		nQSupM:=0
		nQMedM:=0
		nQIntM:=0
		nPAQM:=0
		nPSQM:=0
		nPNQM:=0
		nPApM:=0
		nTotM:=0
		nDirF:=0
		nQSupF:=0
		nQMedM:=0
		nQIntF:=0
		nPAQF:=0
		nPSQF:=0
		nPNQF:=0
		nPApF:=0
		nTotF:=0
	End
Endif	                             
                             
//=================================================================================================================================================
//PAGINA 02========================================================================================================================================
//=================================================================================================================================================
oPrint:StartPage() 		// Inicia uma nova pagina
oPrint:Saybitmap(010,010,cStartPath+"BS02"+".bmp",2500,3400)
nLin:=450  
nCol:=460
For nItem:=1 to 6       
	If nItem==6
		nLin+=80
	Else
		nLin+=20
	Endif
	//****************************************************************************************************************************
	//1.1 - Reparticao de Efetivos                          
	//****************************************************************************************************************************
	//Item 1 - Pessoas ao Servico em 31 de Dezembro
	//Item 2 - Com Contrato Permanente
	//Item 3 - Com Contrato a Termo Certo
	//Item 4 - Com Contrato a Termo Incerto
	//Item 5 - Outros                               
	//****************************************************************************************************************************
	//1.2 - Numero Medio
	//****************************************************************************************************************************
	//Item 6 - Numero medio de pessoas durante o ano
	//==============================================================
	For nSubI:=1 To 3
		nLin+=70
		oPrint:Say(nLin,nCol+120	    ,Space(6-Len(Alltrim(Str(aListEmp[nItem][nSubI][1]))))+Transform(aListEmp[nItem][nSubI][1],"@E 999999")        ,oArial14N)
		oPrint:Say(nLin,nCol+320	    ,Space(6-Len(Alltrim(Str(aListEmp[nItem][nSubI][2]))))+Transform(aListEmp[nItem][nSubI][2],"@E 999999")        ,oArial14N)
		oPrint:Say(nLin,nCol+520	    ,Space(6-Len(Alltrim(Str(aListEmp[nItem][nSubI][3]))))+Transform(aListEmp[nItem][nSubI][3],"@E 999999")        ,oArial14N)
		oPrint:Say(nLin,nCol+720	    ,Space(6-Len(Alltrim(Str(aListEmp[nItem][nSubI][4]))))+Transform(aListEmp[nItem][nSubI][4],"@E 999999")        ,oArial14N)
		oPrint:Say(nLin,nCol+920	    ,Space(6-Len(Alltrim(Str(aListEmp[nItem][nSubI][5]))))+Transform(aListEmp[nItem][nSubI][5],"@E 999999")        ,oArial14N)
		oPrint:Say(nLin,nCol+1120	    ,Space(6-Len(Alltrim(Str(aListEmp[nItem][nSubI][6]))))+Transform(aListEmp[nItem][nSubI][6],"@E 999999")        ,oArial14N)
		oPrint:Say(nLin,nCol+1320	    ,Space(6-Len(Alltrim(Str(aListEmp[nItem][nSubI][7]))))+Transform(aListEmp[nItem][nSubI][7],"@E 999999")        ,oArial14N)
		oPrint:Say(nLin,nCol+1520	    ,Space(6-Len(Alltrim(Str(aListEmp[nItem][nSubI][8]))))+Transform(aListEmp[nItem][nSubI][8],"@E 999999")        ,oArial14N)
		oPrint:Say(nLin,nCol+1720	    ,Space(6-Len(Alltrim(Str(aListEmp[nItem][nSubI][9]))))+Transform(aListEmp[nItem][nSubI][9],"@E 999999")        ,oArial14N)
	Next	
Next   
//****************************************************************************************************************************
//1.3 - Estrutura Nivel Etaria
//****************************************************************************************************************************
nLin+=220
For nEt:=1 To 13                            
	nLin+=70
	oPrint:Say(nLin,nCol+1200	      	,Space(6-Len(Alltrim(Str(aListEmp[7][1][nEt]))))+Transform(aListEmp[7][1][nEt],"@E 999999")        ,oArial14N)
	oPrint:Say(nLin,nCol+1450	      	,Space(6-Len(Alltrim(Str(aListEmp[7][2][nEt]))))+Transform(aListEmp[7][2][nEt],"@E 999999")        ,oArial14N)
	oPrint:Say(nLin,nCol+1700	      	,Space(6-Len(Alltrim(Str(aListEmp[7][3][nEt]))))+Transform(aListEmp[7][3][nEt],"@E 999999")        ,oArial14N)
Next			
//****************************************************************************************************************************
//1.4 - Nivel Etario Medio
//****************************************************************************************************************************
nLin+=220
oPrint:Say(nLin,nCol+1600	            ,Space(6-Len(Alltrim(Str(aListEmp[8][1][1]))))+Transform(aListEmp[8][1][1]  ,"@E 999999")        ,oArial14N)
oPrint:EndPage() 		// Finaliza a pagina

//=================================================================================================================================================
//PAGINA 03========================================================================================================================================
//=================================================================================================================================================
oPrint:StartPage() 		// Inicia uma nova pagina		
oPrint:Saybitmap(010,010,cStartPath+"BS03"+".bmp",2500,3400)  
nLin:=100
nCol:=460  
//****************************************************************************************************************************
//1.5 - Nivel de Antiguidade do Pessoal ao Servico em 31 de Dezembro 
//****************************************************************************************************************************
For nNivAnt:=1 To 6
	nLin+=070
	oPrint:Say(nLin,nCol+1200	    ,Space(6-Len(Alltrim(Str(aListEmp[9][1][nNivAnt]))))+Transform(aListEmp[9][1][nNivAnt],"@E 999999")        ,oArial14N)
	oPrint:Say(nLin,nCol+1450	    ,Space(6-Len(Alltrim(Str(aListEmp[9][2][nNivAnt]))))+Transform(aListEmp[9][2][nNivAnt],"@E 999999")        ,oArial14N)
	oPrint:Say(nLin,nCol+1700	    ,Space(6-Len(Alltrim(Str(aListEmp[9][3][nNivAnt]))))+Transform(aListEmp[9][3][nNivAnt],"@E 999999")        ,oArial14N)
Next
//****************************************************************************************************************************
//1.6 - Trabalhadores Estrangeiros
//****************************************************************************************************************************
nLin+=180
For nEstran:=1 To 4
	nLin+=70
	oPrint:Say(nLin,nCol+1200	    ,Space(6-Len(Alltrim(Str(aListEmp[10][1][nEstran]))))+Transform(aListEmp[10][1][nEstran],"@E 999999")        ,oArial14N)
	oPrint:Say(nLin,nCol+1450	    ,Space(6-Len(Alltrim(Str(aListEmp[10][2][nEstran]))))+Transform(aListEmp[10][2][nEstran],"@E 999999")        ,oArial14N)
	oPrint:Say(nLin,nCol+1700	    ,Space(6-Len(Alltrim(Str(aListEmp[10][3][nEstran]))))+Transform(aListEmp[10][3][nEstran],"@E 999999")        ,oArial14N)
Next
//****************************************************************************************************************************
//1.7 - Trabalhadores Deficiente
//****************************************************************************************************************************
nLin+=220
oPrint:Say(nLin,nCol+1200	    ,Space(6-Len(Alltrim(Str(aListEmp[11][1][1]))))+Transform(aListEmp[11][1][1],"@E 999999")        ,oArial14N)
oPrint:Say(nLin,nCol+1450	    ,Space(6-Len(Alltrim(Str(aListEmp[11][2][1]))))+Transform(aListEmp[11][2][1],"@E 999999")        ,oArial14N)
oPrint:Say(nLin,nCol+1700	    ,Space(6-Len(Alltrim(Str(aListEmp[11][3][1]))))+Transform(aListEmp[11][3][1],"@E 999999")        ,oArial14N)
//****************************************************************************************************************************
//1.8 - Estrutura de Niveis de Habilitacao do Pessoal ao servico em 31 de Dezembro
//****************************************************************************************************************************
//1 - inferior ao 1 ciclo do ensin basico
//2 - 1∞ ciclo do ensino b·sico
//3 - 2∞ ciclo do ensino b·sico
//4 - 3∞ ciclo do ensino b·sico
//5 - Ensino Secundario
//6 - Ensino Profissional
//7 - Ensino Supeior Politecnico
//8 - Ensino Supeior universitario
//9 - Outros			   
nLin+=120		
For nGraIns:=1 To 9    
	nLin+=75
	oPrint:Say(nLin,nCol+1200	    ,Space(6-Len(Alltrim(Str(aListEmp[12][1][nGraIns]))))+Transform(aListEmp[12][1][nGraIns],"@E 999999")        ,oArial14N)
	oPrint:Say(nLin,nCol+1450	    ,Space(6-Len(Alltrim(Str(aListEmp[12][2][nGraIns]))))+Transform(aListEmp[12][2][nGraIns],"@E 999999")        ,oArial14N)
	oPrint:Say(nLin,nCol+1700	    ,Space(6-Len(Alltrim(Str(aListEmp[12][3][nGraIns]))))+Transform(aListEmp[12][3][nGraIns],"@E 999999")        ,oArial14N)
Next
nLin+=200
For nItem:=13 to 17       
nLin+=10
//****************************************************************************************************************************
//1.9 - Contratados a Termo                     
//****************************************************************************************************************************
//Item 13 - Contratados a Termo Certo
//Item 14 - Contratados a Termo InCerto
//Item 15 - Contratados a Termo que passaram ao Quadro Permanente
//Item 16 - Contratados a termo que transitaram do ano anterior
//Item 17 - Numero medio anual de contratados a termo                         
//==============================================================
	For nSubI:=1 To 3      
		nLin+=70
		oPrint:Say(nLin,nCol+320	    ,Space(6-Len(Alltrim(Str(aListEmp[nItem][nSubI][1]))))+Transform(aListEmp[nItem][nSubI][1],"@E 999999")        ,oArial14N)
		oPrint:Say(nLin,nCol+520	    ,Space(6-Len(Alltrim(Str(aListEmp[nItem][nSubI][2]))))+Transform(aListEmp[nItem][nSubI][2],"@E 999999")        ,oArial14N)
		oPrint:Say(nLin,nCol+720	    ,Space(6-Len(Alltrim(Str(aListEmp[nItem][nSubI][3]))))+Transform(aListEmp[nItem][nSubI][3],"@E 999999")        ,oArial14N)
		oPrint:Say(nLin,nCol+920	    ,Space(6-Len(Alltrim(Str(aListEmp[nItem][nSubI][4]))))+Transform(aListEmp[nItem][nSubI][4],"@E 999999")        ,oArial14N)
		oPrint:Say(nLin,nCol+1120	    ,Space(6-Len(Alltrim(Str(aListEmp[nItem][nSubI][5]))))+Transform(aListEmp[nItem][nSubI][5],"@E 999999")        ,oArial14N)
		oPrint:Say(nLin,nCol+1320	    ,Space(6-Len(Alltrim(Str(aListEmp[nItem][nSubI][6]))))+Transform(aListEmp[nItem][nSubI][6],"@E 999999")        ,oArial14N)
		oPrint:Say(nLin,nCol+1520	    ,Space(6-Len(Alltrim(Str(aListEmp[nItem][nSubI][7]))))+Transform(aListEmp[nItem][nSubI][7],"@E 999999")        ,oArial14N)
		oPrint:Say(nLin,nCol+1720	    ,Space(6-Len(Alltrim(Str(aListEmp[nItem][nSubI][8]))))+Transform(aListEmp[nItem][nSubI][8],"@E 999999")        ,oArial14N)
	Next	
Next
oPrint:EndPage() 		// Finaliza a pagina
//=================================================================================================================================================
//PAGINA 04========================================================================================================================================
//=================================================================================================================================================
oPrint:StartPage() 		// Inicia uma nova pagina		
oPrint:Saybitmap(010,010,cStartPath+"BS04"+".bmp",2500,3400)  
nLin:=290 
nCol:=460  
For nItem:=18 to 20       
nLin+=15
//****************************************************************************************************************************
//1.10 - Movimentos de Saida
//****************************************************************************************************************************
//=============================================================
//Item 18 - Saida de Pessoal com Contrato Permanente
//Item 19 - Saida de Pessoal com Contrato a termo
//Item 20 - Saida de Outros Trabalhadores
//==============================================================
	For nSubI:=1 To 3 
		nLin+=65
		oPrint:Say(nLin,nCol+300	    ,Space(6-Len(Alltrim(Str(aListEmp[nItem][nSubI][1]))))+Transform(aListEmp[nItem][nSubI][1],"@E 999999")        ,oArial14N)
		oPrint:Say(nLin,nCol+500	    ,Space(6-Len(Alltrim(Str(aListEmp[nItem][nSubI][2]))))+Transform(aListEmp[nItem][nSubI][2],"@E 999999")        ,oArial14N)
		oPrint:Say(nLin,nCol+700	    ,Space(6-Len(Alltrim(Str(aListEmp[nItem][nSubI][3]))))+Transform(aListEmp[nItem][nSubI][3],"@E 999999")        ,oArial14N)
		oPrint:Say(nLin,nCol+900	    ,Space(6-Len(Alltrim(Str(aListEmp[nItem][nSubI][4]))))+Transform(aListEmp[nItem][nSubI][4],"@E 999999")        ,oArial14N)
		oPrint:Say(nLin,nCol+1100	    ,Space(6-Len(Alltrim(Str(aListEmp[nItem][nSubI][5]))))+Transform(aListEmp[nItem][nSubI][5],"@E 999999")        ,oArial14N)
		oPrint:Say(nLin,nCol+1300	    ,Space(6-Len(Alltrim(Str(aListEmp[nItem][nSubI][6]))))+Transform(aListEmp[nItem][nSubI][6],"@E 999999")        ,oArial14N)
		oPrint:Say(nLin,nCol+1500	    ,Space(6-Len(Alltrim(Str(aListEmp[nItem][nSubI][7]))))+Transform(aListEmp[nItem][nSubI][7],"@E 999999")        ,oArial14N)
		oPrint:Say(nLin,nCol+1700	    ,Space(6-Len(Alltrim(Str(aListEmp[nItem][nSubI][8]))))+Transform(aListEmp[nItem][nSubI][8],"@E 999999")        ,oArial14N)
	Next	
Next                                              
//****************************************************************************************************************************
//Motivos de Saida do Pessoal com Contrato Permanente
//****************************************************************************************************************************
For nCnt:=1 to 8
	aTotMSP[nCnt]:=0
Next
nLin+=300
For nMotSai:=1 To 10
	nLin+=55
	oPrint:Say(nLin,nCol+300	    ,Space(6-Len(Alltrim(Str(aListEmp[21][nMotSAi][1]))))+Transform(aListEmp[21][nMotSAi][1],"@E 999999")        ,oArial14N)
	oPrint:Say(nLin,nCol+500	    ,Space(6-Len(Alltrim(Str(aListEmp[21][nMotSAi][2]))))+Transform(aListEmp[21][nMotSAi][2],"@E 999999")        ,oArial14N)
	oPrint:Say(nLin,nCol+700	    ,Space(6-Len(Alltrim(Str(aListEmp[21][nMotSAi][3]))))+Transform(aListEmp[21][nMotSAi][3],"@E 999999")        ,oArial14N)
	oPrint:Say(nLin,nCol+900	    ,Space(6-Len(Alltrim(Str(aListEmp[21][nMotSAi][4]))))+Transform(aListEmp[21][nMotSAi][4],"@E 999999")        ,oArial14N)
	oPrint:Say(nLin,nCol+1100	    ,Space(6-Len(Alltrim(Str(aListEmp[21][nMotSAi][5]))))+Transform(aListEmp[21][nMotSAi][5],"@E 999999")        ,oArial14N)
	oPrint:Say(nLin,nCol+1300	    ,Space(6-Len(Alltrim(Str(aListEmp[21][nMotSAi][6]))))+Transform(aListEmp[21][nMotSAi][6],"@E 999999")        ,oArial14N)
	oPrint:Say(nLin,nCol+1500	    ,Space(6-Len(Alltrim(Str(aListEmp[21][nMotSAi][7]))))+Transform(aListEmp[21][nMotSAi][7],"@E 999999")        ,oArial14N)
	oPrint:Say(nLin,nCol+1700	    ,Space(6-Len(Alltrim(Str(aListEmp[21][nMotSAi][8]))))+Transform(aListEmp[21][nMotSAi][8],"@E 999999")        ,oArial14N)
	aTotMSP[1]+=aListEmp[21][nMotSAi][1]
	aTotMSP[2]+=aListEmp[21][nMotSAi][2]
	aTotMSP[3]+=aListEmp[21][nMotSAi][3]
	aTotMSP[4]+=aListEmp[21][nMotSAi][4]
	aTotMSP[5]+=aListEmp[21][nMotSAi][5]
	aTotMSP[6]+=aListEmp[21][nMotSAi][6]
	aTotMSP[7]+=aListEmp[21][nMotSAi][7]
	aTotMSP[8]+=aListEmp[21][nMotSAi][8]
Next	       
//=============================================================
//Total(motivos de saidas de pessoal com contrato permanente)		
//=============================================================
nLin+=70
oPrint:Say(nLin,nCol+300	    ,Space(6-Len(Alltrim(Str(aTotMSP[1]))))+Transform(aTotMSP[1],"@E 999999")        ,oArial14N)
oPrint:Say(nLin,nCol+500	    ,Space(6-Len(Alltrim(Str(aTotMSP[2]))))+Transform(aTotMSP[2],"@E 999999")        ,oArial14N)
oPrint:Say(nLin,nCol+700	    ,Space(6-Len(Alltrim(Str(aTotMSP[3]))))+Transform(aTotMSP[3],"@E 999999")        ,oArial14N)
oPrint:Say(nLin,nCol+900	    ,Space(6-Len(Alltrim(Str(aTotMSP[4]))))+Transform(aTotMSP[4],"@E 999999")        ,oArial14N)
oPrint:Say(nLin,nCol+1100	    ,Space(6-Len(Alltrim(Str(aTotMSP[5]))))+Transform(aTotMSP[5],"@E 999999")        ,oArial14N)
oPrint:Say(nLin,nCol+1300	    ,Space(6-Len(Alltrim(Str(aTotMSP[6]))))+Transform(aTotMSP[6],"@E 999999")        ,oArial14N)
oPrint:Say(nLin,nCol+1500	    ,Space(6-Len(Alltrim(Str(aTotMSP[7]))))+Transform(aTotMSP[7],"@E 999999")        ,oArial14N)
oPrint:Say(nLin,nCol+1700	    ,Space(6-Len(Alltrim(Str(aTotMSP[8]))))+Transform(aTotMSP[8],"@E 999999")        ,oArial14N)
//****************************************************************************************************************************
//Motivos de Saida do Pessoal com Contrato a Termo
//****************************************************************************************************************************
//=============================================================
//1 - Por cessacao do contrato a termo incerto
//2 - Por cessacao do contrato a termo incerto
//3 - Por antecipacao da cessacao do contrato a termo certo
//4 - Por antecipacao da cessacao do contrato a termo Incerto
//=============================================================
nLin+=220
For nCnt:=1 to 8
	aTotMST[nCnt]:=0
Next      
For nMotSai:=1 To 4
	If nMotSai==4
		nLin+=160
	Else	
		nLin+=120
	Endif
	oPrint:Say(nLin,nCol+300	    ,Space(6-Len(Alltrim(Str(aListEmp[22][nMotSAi][1]))))+Transform(aListEmp[22][nMotSAi][1],"@E 999999")        ,oArial14N)
	oPrint:Say(nLin,nCol+500	    ,Space(6-Len(Alltrim(Str(aListEmp[22][nMotSAi][1]))))+Transform(aListEmp[22][nMotSAi][2],"@E 999999")        ,oArial14N)
	oPrint:Say(nLin,nCol+700	    ,Space(6-Len(Alltrim(Str(aListEmp[22][nMotSAi][1]))))+Transform(aListEmp[22][nMotSAi][3],"@E 999999")        ,oArial14N)
	oPrint:Say(nLin,nCol+900	    ,Space(6-Len(Alltrim(Str(aListEmp[22][nMotSAi][1]))))+Transform(aListEmp[22][nMotSAi][4],"@E 999999")        ,oArial14N)
	oPrint:Say(nLin,nCol+1100	    ,Space(6-Len(Alltrim(Str(aListEmp[22][nMotSAi][1]))))+Transform(aListEmp[22][nMotSAi][5],"@E 999999")        ,oArial14N)
	oPrint:Say(nLin,nCol+1300	    ,Space(6-Len(Alltrim(Str(aListEmp[22][nMotSAi][1]))))+Transform(aListEmp[22][nMotSAi][6],"@E 999999")        ,oArial14N)
	oPrint:Say(nLin,nCol+1500	    ,Space(6-Len(Alltrim(Str(aListEmp[22][nMotSAi][1]))))+Transform(aListEmp[22][nMotSAi][7],"@E 999999")        ,oArial14N)
	oPrint:Say(nLin,nCol+1700	    ,Space(6-Len(Alltrim(Str(aListEmp[22][nMotSAi][1]))))+Transform(aListEmp[22][nMotSAi][8],"@E 999999")        ,oArial14N)
	aTotMST[1]+=aListEmp[22][nMotSAi][1]
	aTotMST[2]+=aListEmp[22][nMotSAi][2]
	aTotMST[3]+=aListEmp[22][nMotSAi][3]
	aTotMST[4]+=aListEmp[22][nMotSAi][4]
	aTotMST[5]+=aListEmp[22][nMotSAi][5]
	aTotMST[6]+=aListEmp[22][nMotSAi][6]
	aTotMST[7]+=aListEmp[22][nMotSAi][7]
	aTotMST[8]+=aListEmp[22][nMotSAi][8]
Next	
//=============================================================
//Total(motivos de saidas de pessoal com contrato a termo)		
//=============================================================
nLin+=120
oPrint:Say(nLin,nCol+300		    ,Space(6-Len(Alltrim(Str(aTotMST[1]))))+Transform(aTotMST[1],"@E 999999")        ,oArial14N)
oPrint:Say(nLin,nCol+500		    ,Space(6-Len(Alltrim(Str(aTotMST[2]))))+Transform(aTotMST[2],"@E 999999")        ,oArial14N)
oPrint:Say(nLin,nCol+700		    ,Space(6-Len(Alltrim(Str(aTotMST[3]))))+Transform(aTotMST[3],"@E 999999")        ,oArial14N)
oPrint:Say(nLin,nCol+900		    ,Space(6-Len(Alltrim(Str(aTotMST[4]))))+Transform(aTotMST[4],"@E 999999")        ,oArial14N)
oPrint:Say(nLin,nCol+1100		    ,Space(6-Len(Alltrim(Str(aTotMST[5]))))+Transform(aTotMST[5],"@E 999999")        ,oArial14N)
oPrint:Say(nLin,nCol+1300		    ,Space(6-Len(Alltrim(Str(aTotMST[6]))))+Transform(aTotMST[6],"@E 999999")        ,oArial14N)
oPrint:Say(nLin,nCol+1500		    ,Space(6-Len(Alltrim(Str(aTotMST[7]))))+Transform(aTotMST[7],"@E 999999")        ,oArial14N)
oPrint:Say(nLin,nCol+1700		    ,Space(6-Len(Alltrim(Str(aTotMST[8]))))+Transform(aTotMST[8],"@E 999999")        ,oArial14N)

//****************************************************************************************************************************
//Outros Motivos de Saida do pessoal com contrato permanente ou a Termo
//****************************************************************************************************************************
//=============================================================
//Situacoes especiais de saida por impedimento prolongado
//=============================================================
nLin+=450
oPrint:Say(nLin,nCol+300		    ,Space(6-Len(Alltrim(Str(aListEmp[23][1][1]))))+Transform(aListEmp[23][1][1],"@E 999999")        ,oArial14N)
oPrint:Say(nLin,nCol+500		    ,Space(6-Len(Alltrim(Str(aListEmp[23][1][2]))))+Transform(aListEmp[23][1][2],"@E 999999")        ,oArial14N)
oPrint:Say(nLin,nCol+700		    ,Space(6-Len(Alltrim(Str(aListEmp[23][1][3]))))+Transform(aListEmp[23][1][3],"@E 999999")        ,oArial14N)
oPrint:Say(nLin,nCol+900		    ,Space(6-Len(Alltrim(Str(aListEmp[23][1][4]))))+Transform(aListEmp[23][1][4],"@E 999999")        ,oArial14N)
oPrint:Say(nLin,nCol+1100		    ,Space(6-Len(Alltrim(Str(aListEmp[23][1][5]))))+Transform(aListEmp[23][1][5],"@E 999999")        ,oArial14N)
oPrint:Say(nLin,nCol+1300		    ,Space(6-Len(Alltrim(Str(aListEmp[23][1][6]))))+Transform(aListEmp[23][1][6],"@E 999999")        ,oArial14N)
oPrint:Say(nLin,nCol+1500		    ,Space(6-Len(Alltrim(Str(aListEmp[23][1][7]))))+Transform(aListEmp[23][1][7],"@E 999999")        ,oArial14N)
oPrint:Say(nLin,nCol+1700		    ,Space(6-Len(Alltrim(Str(aListEmp[23][1][8]))))+Transform(aListEmp[23][1][8],"@E 999999")        ,oArial14N)
		
oPrint:EndPage() 		// Finaliza a pagina
//=================================================================================================================================================
//PAGINA 05========================================================================================================================================
//=================================================================================================================================================
oPrint:StartPage() 		// Inicia uma nova pagina		
oPrint:Saybitmap(010,010,cStartPath+"BS05"+".bmp",2500,3400)  
nLin:=390 
nCol:=460  
//****************************************************************************************************************************
//1.14 - Postos de Trabalho
//****************************************************************************************************************************
For nCnt:=1 to 9
	If !Empty(aListEmp2[1][nCnt][1])
		oPrint:Say(nLin,nCol+400 ,aListEmp2[1][nCnt][1]																			       ,oArial14N)
		oPrint:Say(nLin,nCol+1700,Space(6-Len(Alltrim(Str(aListEmp2[1][nCnt][3]))))+Transform(aListEmp2[1][nCnt][3],"@E 999999")       ,oArial14N)
	Endif
	nLin+=150
Next    
nLin+=130
//****************************************************************************************************************************
//1.15 - PROMOCOES
//****************************************************************************************************************************
//==============================================================
//Item 25 - Antiguidade(Promocoes)				
//Item 26 - Merito(Promocoes)		
//Item 27 - Outras(Promocoes)		
//Item 28 - Total(Promocoes)		
//==============================================================
//****************************************************************************************************************************
//1.16 - Reconversoes/Reclassificacoes
//****************************************************************************************************************************
//==============================================================
//Item 29 - Numero de Trabalhadores(Reconversoes/Reclassificacoes)		
//==============================================================
For nItem:=25 to 29       
	If nItem==29
		nLin+=260
	Else
		nLin+=10
	Endif

	For nSubI:=1 To 3
		nLin+=70
		oPrint:Say(nLin,nCol+300	    ,Space(6-Len(Alltrim(Str(aListEmp[nItem][nSubI][1]))))+Transform(aListEmp[nItem][nSubI][1],"@E 999999")        ,oArial14N)
		oPrint:Say(nLin,nCol+500	    ,Space(6-Len(Alltrim(Str(aListEmp[nItem][nSubI][2]))))+Transform(aListEmp[nItem][nSubI][2],"@E 999999")        ,oArial14N)
		oPrint:Say(nLin,nCol+700	    ,Space(6-Len(Alltrim(Str(aListEmp[nItem][nSubI][3]))))+Transform(aListEmp[nItem][nSubI][3],"@E 999999")        ,oArial14N)
		oPrint:Say(nLin,nCol+900	    ,Space(6-Len(Alltrim(Str(aListEmp[nItem][nSubI][4]))))+Transform(aListEmp[nItem][nSubI][4],"@E 999999")        ,oArial14N)
		oPrint:Say(nLin,nCol+1100	    ,Space(6-Len(Alltrim(Str(aListEmp[nItem][nSubI][5]))))+Transform(aListEmp[nItem][nSubI][5],"@E 999999")        ,oArial14N)
		oPrint:Say(nLin,nCol+1300	    ,Space(6-Len(Alltrim(Str(aListEmp[nItem][nSubI][6]))))+Transform(aListEmp[nItem][nSubI][6],"@E 999999")        ,oArial14N)
		oPrint:Say(nLin,nCol+1500	    ,Space(6-Len(Alltrim(Str(aListEmp[nItem][nSubI][7]))))+Transform(aListEmp[nItem][nSubI][7],"@E 999999")        ,oArial14N)
		oPrint:Say(nLin,nCol+1700	    ,Space(6-Len(Alltrim(Str(aListEmp[nItem][nSubI][8]))))+Transform(aListEmp[nItem][nSubI][8],"@E 999999")        ,oArial14N)
	Next
Next	
oPrint:EndPage()   	   // Finaliza a pagina
//=================================================================================================================================================
//PAGINA 06========================================================================================================================================
//=================================================================================================================================================
oPrint:StartPage() 		// Inicia uma nova pagina		
oPrint:Saybitmap(010,010,cStartPath+"BS06"+".bmp",2500,3400)  
nLin:=520 
nCol:=860  
//****************************************************************************************************************************
//1.17 - Tempo de Trabalho
//****************************************************************************************************************************
//==============================================================
//1.17.1 - Periodo Normal de Trabalho em Vigor em Dezembro	
//==============================================================
For nCnt:=1 to 12 
	If !Empty(aListEmp2[2][nCnt][1])
		oPrint:Say(nLin,nCol+1000 ,Alltrim(Str(aListEmp2[2][nCnt][1]))																   ,oArial14N)
		oPrint:Say(nLin,nCol+1300,Space(6-Len(Alltrim(Str(aListEmp2[2][nCnt][3]))))+Transform(aListEmp2[2][nCnt][3],"@E 999999")       ,oArial14N)
	Endif	
	nLin+=75
Next   
nlin+=85
//==============================================================
//1.17.2 - Tipos de Horarios Predominantes durante o Ano	
//==============================================================                                                  
//1-Horario Normal Fixo
//2-Horario Flexivel        
//3-Horario de Turno(Fixo e/ou rotativo)
//4-Horario irregular e/ou movel
//5-Horario reduzido
//6-insencao de horario     
//==============================================================                                                  
For nCnt:=1 to 7
	nLin+=75  
	oPrint:Say(nLin,nCol+1300		    ,Space(6-Len(Alltrim(Str(aListEmp[30][1][nCnt]))))+Transform(aListEmp[30][1][nCnt],"@E 999999")        ,oArial14N)
Next
//==============================================================
//1.17.3- Potencia Maxima Anual(horas trabalhaveis)            
//==============================================================                                                                                       
nLin+=235
oPrint:Say(nLin,nCol+1300		    ,Space(6-Len(Alltrim(Str(aListEmp[31][1][1]))))+Transform(aListEmp[31][1][1],"@E 999999")        ,oArial14N)
//==============================================================
//1.17.4 - Total de Horas Efectivamente Trabalhadas
//==============================================================
nLin+=080
oPrint:Say(nLin,nCol+1300		    ,Space(6-Len(Alltrim(Str(aListEmp[32][1][1]))))+Transform(aListEmp[32][1][1],"@E 999999")        ,oArial14N)
//==============================================================
//1.17.5.1 - Em Dias uteis
//==============================================================
nLin+=130
oPrint:Say(nLin,nCol+1300		    ,Space(6-Len(Alltrim(Str(aListEmp[33][1][1]))))+Transform(aListEmp[33][1][1],"@E 999999")        ,oArial14N)
nLin+=075
oPrint:Say(nLin,nCol+1300		    ,Space(6-Len(Alltrim(Str(aListEmp[33][1][2]))))+Transform(aListEmp[33][1][2],"@E 999999")        ,oArial14N)
nLin+=075
oPrint:Say(nLin,nCol+1300		    ,Space(6-Len(Alltrim(Str(aListEmp[33][1][3]))))+Transform(aListEmp[33][1][3],"@E 999999")        ,oArial14N)
//==============================================================
//1.17.5.2 - Em dia de descanso complementar e feriado
nLin+=075
oPrint:Say(nLin,nCol+1300		    ,Space(6-Len(Alltrim(Str(aListEmp[34][1][1]))))+Transform(aListEmp[34][1][1],"@E 999999")        ,oArial14N)
nLin+=075                                                                                               
oPrint:Say(nLin,nCol+1300		    ,Space(6-Len(Alltrim(Str(aListEmp[34][1][2]))))+Transform(aListEmp[34][1][2],"@E 999999")        ,oArial14N)
nLin+=075
oPrint:Say(nLin,nCol+1300		    ,Space(6-Len(Alltrim(Str(aListEmp[34][1][3]))))+Transform(aListEmp[34][1][3],"@E 999999")        ,oArial14N)
//==============================================================
//1.17.5.3 - Em dia de descanso obrigatorio 
//==============================================================
nLin+=075
oPrint:Say(nLin,nCol+1300		    ,Space(6-Len(Alltrim(Str(aListEmp[35][1][1]))))+Transform(aListEmp[35][1][1],"@E 999999")        ,oArial14N)
nLin+=075
oPrint:Say(nLin,nCol+1300		    ,Space(6-Len(Alltrim(Str(aListEmp[35][1][2]))))+Transform(aListEmp[35][1][2],"@E 999999")        ,oArial14N)
nLin+=075
oPrint:Say(nLin,nCol+1300		    ,Space(6-Len(Alltrim(Str(aListEmp[35][1][3]))))+Transform(aListEmp[35][1][3],"@E 999999")        ,oArial14N)


oPrint:EndPage()   		// Finaliza a pagina

//=================================================================================================================================================
//PAGINA 07========================================================================================================================================
//=================================================================================================================================================
oPrint:StartPage() 		// Inicia uma nova pagina		
oPrint:Saybitmap(010,010,cStartPath+"BS07"+".bmp",2500,3400)  
nLin:=250
nCol:=460
//****************************************************************************************************************************
//1.18 - Ausencias ao Trabalho
//****************************************************************************************************************************
//==============================================================
//1.18.1 - Por acidente de trabalho (Ausencias ao Trabalho)
//==============================================================
oPrint:Say(nLin,nCol+1300		    ,Space(6-Len(Alltrim(Str(aListEmp[36][1][1]))))+Transform(aListEmp[36][1][1],"@E 999999")        ,oArial14N)
oPrint:Say(nLin,nCol+1700		    ,Space(6-Len(Alltrim(Str(aListEmp[36][2][1]))))+Transform(aListEmp[36][2][1],"@E 999999")        ,oArial14N)
nLin+=60
oPrint:Say(nLin,nCol+1300		    ,Space(6-Len(Alltrim(Str(aListEmp[36][1][2]))))+Transform(aListEmp[36][1][2],"@E 999999")        ,oArial14N)
oPrint:Say(nLin,nCol+1700		    ,Space(6-Len(Alltrim(Str(aListEmp[36][2][2]))))+Transform(aListEmp[36][2][2],"@E 999999")        ,oArial14N)
nLin+=60
oPrint:Say(nLin,nCol+1300		    ,Space(6-Len(Alltrim(Str(aListEmp[36][1][3]))))+Transform(aListEmp[36][1][3],"@E 999999")        ,oArial14N)
oPrint:Say(nLin,nCol+1700		    ,Space(6-Len(Alltrim(Str(aListEmp[36][2][3]))))+Transform(aListEmp[36][2][3],"@E 999999")        ,oArial14N)
//==============================================================
//1.18.2 - Por Doenca(Total)  
//==============================================================
nLin+=75
oPrint:Say(nLin,nCol+1300		    ,Space(6-Len(Alltrim(Str(aListEmp[37][1][1]))))+Transform(aListEmp[37][1][1],"@E 999999")        ,oArial14N)
oPrint:Say(nLin,nCol+1700		    ,Space(6-Len(Alltrim(Str(aListEmp[37][2][1]))))+Transform(aListEmp[37][2][1],"@E 999999")        ,oArial14N)
nLin+=65
oPrint:Say(nLin,nCol+1300		    ,Space(6-Len(Alltrim(Str(aListEmp[37][1][2]))))+Transform(aListEmp[37][1][2],"@E 999999")        ,oArial14N)
oPrint:Say(nLin,nCol+1700		    ,Space(6-Len(Alltrim(Str(aListEmp[37][2][2]))))+Transform(aListEmp[37][2][2],"@E 999999")        ,oArial14N)
nLin+=65
oPrint:Say(nLin,nCol+1300		    ,Space(6-Len(Alltrim(Str(aListEmp[37][1][3]))))+Transform(aListEmp[37][1][3],"@E 999999")        ,oArial14N)
oPrint:Say(nLin,nCol+1700		    ,Space(6-Len(Alltrim(Str(aListEmp[37][2][3]))))+Transform(aListEmp[37][2][3],"@E 999999")        ,oArial14N)
//==============================================================
//1.18.2.1 - Por Doencas Profissionais                          
//==============================================================
nLin+=65
oPrint:Say(nLin,nCol+1300		    ,Space(6-Len(Alltrim(Str(aListEmp[38][1][1]))))+Transform(aListEmp[38][1][1],"@E 999999")        ,oArial14N)
oPrint:Say(nLin,nCol+1700		    ,Space(6-Len(Alltrim(Str(aListEmp[38][2][1]))))+Transform(aListEmp[38][2][1],"@E 999999")        ,oArial14N)
nLin+=65                                                              
oPrint:Say(nLin,nCol+1300		    ,Space(6-Len(Alltrim(Str(aListEmp[38][1][2]))))+Transform(aListEmp[38][1][2],"@E 999999")        ,oArial14N)
oPrint:Say(nLin,nCol+1700		    ,Space(6-Len(Alltrim(Str(aListEmp[38][2][2]))))+Transform(aListEmp[38][2][2],"@E 999999")        ,oArial14N)
nLin+=65
oPrint:Say(nLin,nCol+1300		    ,Space(6-Len(Alltrim(Str(aListEmp[38][1][3]))))+Transform(aListEmp[38][1][3],"@E 999999")        ,oArial14N)
oPrint:Say(nLin,nCol+1700		    ,Space(6-Len(Alltrim(Str(aListEmp[38][2][3]))))+Transform(aListEmp[38][2][3],"@E 999999")        ,oArial14N)
//==============================================================
//1.18.3 - Por suspensoes disciplinares                         
//==============================================================
nLin+=75
oPrint:Say(nLin,nCol+1300		    ,Space(6-Len(Alltrim(Str(aListEmp[39][1][1]))))+Transform(aListEmp[39][1][1],"@E 999999")        ,oArial14N)
oPrint:Say(nLin,nCol+1700   	    ,Space(6-Len(Alltrim(Str(aListEmp[39][2][1]))))+Transform(aListEmp[39][2][1],"@E 999999")        ,oArial14N)
nLin+=65
oPrint:Say(nLin,nCol+1300		    ,Space(6-Len(Alltrim(Str(aListEmp[39][1][2]))))+Transform(aListEmp[39][1][2],"@E 999999")        ,oArial14N)
oPrint:Say(nLin,nCol+1700		    ,Space(6-Len(Alltrim(Str(aListEmp[39][2][2]))))+Transform(aListEmp[39][2][2],"@E 999999")        ,oArial14N)
nLin+=65
oPrint:Say(nLin,nCol+1300		    ,Space(6-Len(Alltrim(Str(aListEmp[39][1][3]))))+Transform(aListEmp[39][1][3],"@E 999999")        ,oArial14N)
oPrint:Say(nLin,nCol+1700		    ,Space(6-Len(Alltrim(Str(aListEmp[39][2][3]))))+Transform(aListEmp[39][2][3],"@E 999999")        ,oArial14N)
//==============================================================
//1.18.4 - Por assistencia inadiavel                            
//==============================================================
nLin+=75
oPrint:Say(nLin,nCol+1300		    ,Space(6-Len(Alltrim(Str(aListEmp[40][1][1]))))+Transform(aListEmp[40][1][1],"@E 999999")        ,oArial14N)
oPrint:Say(nLin,nCol+1700		    ,Space(6-Len(Alltrim(Str(aListEmp[40][2][1]))))+Transform(aListEmp[40][2][1],"@E 999999")        ,oArial14N)
nLin+=65
oPrint:Say(nLin,nCol+1300		    ,Space(6-Len(Alltrim(Str(aListEmp[40][1][2]))))+Transform(aListEmp[40][1][2],"@E 999999")        ,oArial14N)
oPrint:Say(nLin,nCol+1700		    ,Space(6-Len(Alltrim(Str(aListEmp[40][2][2]))))+Transform(aListEmp[40][2][2],"@E 999999")        ,oArial14N)
nLin+=65
oPrint:Say(nLin,nCol+1300		    ,Space(6-Len(Alltrim(Str(aListEmp[40][1][3]))))+Transform(aListEmp[40][1][3],"@E 999999")        ,oArial14N)
oPrint:Say(nLin,nCol+1700		    ,Space(6-Len(Alltrim(Str(aListEmp[40][2][3]))))+Transform(aListEmp[40][2][3],"@E 999999")        ,oArial14N)
//==============================================================
//1.18.5 - Por Maternidade/Paternidade                          
//==============================================================
nLin+=75
oPrint:Say(nLin,nCol+1300		    ,Space(6-Len(Alltrim(Str(aListEmp[41][1][3]))))+Transform(aListEmp[41][1][3],"@E 999999")        ,oArial14N)
oPrint:Say(nLin,nCol+1700		    ,Space(6-Len(Alltrim(Str(aListEmp[41][2][3]))))+Transform(aListEmp[41][2][3],"@E 999999")        ,oArial14N)
//==============================================================
//1.18.6 - Por outras causas                                    
//==============================================================
nLin+=90
oPrint:Say(nLin,nCol+1300		    ,Space(6-Len(Alltrim(Str(aListEmp[42][1][1]))))+Transform(aListEmp[42][1][1],"@E 999999")        ,oArial14N)
oPrint:Say(nLin,nCol+1700		    ,Space(6-Len(Alltrim(Str(aListEmp[42][2][1]))))+Transform(aListEmp[42][2][1],"@E 999999")        ,oArial14N)
nLin+=65
oPrint:Say(nLin,nCol+1300		    ,Space(6-Len(Alltrim(Str(aListEmp[42][1][2]))))+Transform(aListEmp[42][1][2],"@E 999999")        ,oArial14N)
oPrint:Say(nLin,nCol+1700		    ,Space(6-Len(Alltrim(Str(aListEmp[42][2][2]))))+Transform(aListEmp[42][2][2],"@E 999999")        ,oArial14N)
nLin+=65
oPrint:Say(nLin,nCol+1300		    ,Space(6-Len(Alltrim(Str(aListEmp[42][1][3]))))+Transform(aListEmp[42][1][3],"@E 999999")        ,oArial14N)
oPrint:Say(nLin,nCol+1700		    ,Space(6-Len(Alltrim(Str(aListEmp[42][2][3]))))+Transform(aListEmp[42][2][3],"@E 999999")        ,oArial14N)
//==============================================================
//1.18.7 - Total de Ausencias(Remuneradas e nao remuneradas)    
//==============================================================
nLin+=75
oPrint:Say(nLin,nCol+1300		    ,Space(6-Len(Alltrim(Str(aListEmp[43][1][1]))))+Transform(aListEmp[43][1][1],"@E 999999")        ,oArial14N)
oPrint:Say(nLin,nCol+1700		    ,Space(6-Len(Alltrim(Str(aListEmp[43][2][1]))))+Transform(aListEmp[43][2][1],"@E 999999")        ,oArial14N)
nLin+=65
oPrint:Say(nLin,nCol+1300		    ,Space(6-Len(Alltrim(Str(aListEmp[43][1][2]))))+Transform(aListEmp[43][1][2],"@E 999999")        ,oArial14N)
oPrint:Say(nLin,nCol+1700		    ,Space(6-Len(Alltrim(Str(aListEmp[43][2][2]))))+Transform(aListEmp[43][2][2],"@E 999999")        ,oArial14N)
nLin+=65
oPrint:Say(nLin,nCol+1300		    ,Space(6-Len(Alltrim(Str(aListEmp[43][1][3]))))+Transform(aListEmp[43][1][3],"@E 999999")        ,oArial14N)
oPrint:Say(nLin,nCol+1700		    ,Space(6-Len(Alltrim(Str(aListEmp[43][2][3]))))+Transform(aListEmp[43][2][3],"@E 999999")        ,oArial14N)
//==============================================================
//1.18.7.1 - Por Ausencia Remuneradas				            
//==============================================================
nLin+=70
oPrint:Say(nLin,nCol+1300		    ,Space(6-Len(Alltrim(Str(aListEmp[44][1][1]))))+Transform(aListEmp[44][1][1],"@E 999999")        ,oArial14N)
oPrint:Say(nLin,nCol+1700		    ,Space(6-Len(Alltrim(Str(aListEmp[44][2][1]))))+Transform(aListEmp[44][2][1],"@E 999999")        ,oArial14N)
nLin+=65
oPrint:Say(nLin,nCol+1300		    ,Space(6-Len(Alltrim(Str(aListEmp[44][1][2]))))+Transform(aListEmp[44][1][2],"@E 999999")        ,oArial14N)
oPrint:Say(nLin,nCol+1700		    ,Space(6-Len(Alltrim(Str(aListEmp[44][2][2]))))+Transform(aListEmp[44][2][2],"@E 999999")        ,oArial14N)
nLin+=65
oPrint:Say(nLin,nCol+1300		    ,Space(6-Len(Alltrim(Str(aListEmp[44][1][3]))))+Transform(aListEmp[44][1][3],"@E 999999")        ,oArial14N)
oPrint:Say(nLin,nCol+1700		    ,Space(6-Len(Alltrim(Str(aListEmp[44][2][3]))))+Transform(aListEmp[44][2][3],"@E 999999")        ,oArial14N)
//==============================================================
//1.18.7.2 - Por Ausencia nao Remuneradas                       
//==============================================================
nLin+=70
oPrint:Say(nLin,nCol+1300		    ,Space(6-Len(Alltrim(Str(aListEmp[45][1][1]))))+Transform(aListEmp[45][1][1],"@E 999999")        ,oArial14N)
oPrint:Say(nLin,nCol+1700		    ,Space(6-Len(Alltrim(Str(aListEmp[45][2][1]))))+Transform(aListEmp[45][2][1],"@E 999999")        ,oArial14N)
nLin+=65
oPrint:Say(nLin,nCol+1300		    ,Space(6-Len(Alltrim(Str(aListEmp[45][1][2]))))+Transform(aListEmp[45][1][2],"@E 999999")        ,oArial14N)
oPrint:Say(nLin,nCol+1700		    ,Space(6-Len(Alltrim(Str(aListEmp[45][2][2]))))+Transform(aListEmp[45][2][2],"@E 999999")        ,oArial14N)
nLin+=65
oPrint:Say(nLin,nCol+1300		    ,Space(6-Len(Alltrim(Str(aListEmp[45][1][3]))))+Transform(aListEmp[45][1][3],"@E 999999")        ,oArial14N)
oPrint:Say(nLin,nCol+1700		    ,Space(6-Len(Alltrim(Str(aListEmp[45][2][3]))))+Transform(aListEmp[45][2][3],"@E 999999")        ,oArial14N)
//****************************************************************************************************************************
//1.19 - Horas nao trabalhadas
//****************************************************************************************************************************
//==============================================================
//1.19.1 - Por formacao profissional                            
//==============================================================
nLin+=260
oPrint:Say(nLin,nCol+1700		    ,Space(6-Len(Alltrim(Str(aListEmp[46][1][1]))))+Transform(aListEmp[46][1][1],"@E 999999")        ,oArial14N)
nLin+=65
oPrint:Say(nLin,nCol+1700		    ,Space(6-Len(Alltrim(Str(aListEmp[46][1][2]))))+Transform(aListEmp[46][1][2],"@E 999999")        ,oArial14N)
nLin+=65
oPrint:Say(nLin,nCol+1700		    ,Space(6-Len(Alltrim(Str(aListEmp[46][1][3]))))+Transform(aListEmp[46][1][3],"@E 999999")        ,oArial14N)

//==============================================================				
//1.19.2 - Por reducao legal da atividade                       
//==============================================================
nLin+=70
oPrint:Say(nLin,nCol+1700		    ,Space(6-Len(Alltrim(Str(aListEmp[47][1][1]))))+Transform(aListEmp[47][1][1],"@E 999999")        ,oArial14N)
nLin+=65
oPrint:Say(nLin,nCol+1700		    ,Space(6-Len(Alltrim(Str(aListEmp[47][1][2]))))+Transform(aListEmp[47][1][2],"@E 999999")        ,oArial14N)
nLin+=65
oPrint:Say(nLin,nCol+1700		    ,Space(6-Len(Alltrim(Str(aListEmp[47][1][3]))))+Transform(aListEmp[47][1][3],"@E 999999")        ,oArial14N)
//==============================================================				
//1.19.3 - Por desemprego interno                               
//==============================================================
nLin+=70
oPrint:Say(nLin,nCol+1700		    ,Space(6-Len(Alltrim(Str(aListEmp[48][1][1]))))+Transform(aListEmp[48][1][1],"@E 999999")        ,oArial14N)
nLin+=65
oPrint:Say(nLin,nCol+1700		    ,Space(6-Len(Alltrim(Str(aListEmp[48][1][2]))))+Transform(aListEmp[48][1][2],"@E 999999")        ,oArial14N)
nLin+=65
oPrint:Say(nLin,nCol+1700		    ,Space(6-Len(Alltrim(Str(aListEmp[48][1][3]))))+Transform(aListEmp[48][1][3],"@E 999999")        ,oArial14N)
//==============================================================				
//1.19.4 - Por Descanso suplementar                             
//==============================================================
nLin+=70
oPrint:Say(nLin,nCol+1700		    ,Space(6-Len(Alltrim(Str(aListEmp[47][1][1]))))+Transform(aListEmp[49][1][1],"@E 999999")        ,oArial14N)
nLin+=65
oPrint:Say(nLin,nCol+1700		    ,Space(6-Len(Alltrim(Str(aListEmp[47][1][2]))))+Transform(aListEmp[49][1][2],"@E 999999")        ,oArial14N)
nLin+=65
oPrint:Say(nLin,nCol+1700		    ,Space(6-Len(Alltrim(Str(aListEmp[47][1][3]))))+Transform(aListEmp[49][1][3],"@E 999999")        ,oArial14N)
//==============================================================				
//1.19.5 - Por Greves/paralizacoes                              
//==============================================================
nLin+=70
oPrint:Say(nLin,nCol+1700		    ,Space(6-Len(Alltrim(Str(aListEmp[50][1][1]))))+Transform(aListEmp[50][1][1],"@E 999999")        ,oArial14N)
nLin+=65
oPrint:Say(nLin,nCol+1700		    ,Space(6-Len(Alltrim(Str(aListEmp[50][1][2]))))+Transform(aListEmp[50][1][2],"@E 999999")        ,oArial14N)
nLin+=65
oPrint:Say(nLin,nCol+1700		    ,Space(6-Len(Alltrim(Str(aListEmp[50][1][3]))))+Transform(aListEmp[50][1][3],"@E 999999")        ,oArial14N)

oPrint:EndPage() 		// Finaliza a pagina
Return
/*/
‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±⁄ƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒø±±
±±≥Funcao    ≥RGERBS ≥ Autor ≥ Marcos Kato              ≥ Data ≥ 12/07/07 ≥±±
±±≥ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥Descricao ≥Detalhe do Relatorio                                        ≥±±
±±√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥ Uso      ≥ Onsten                                                  	  ≥±±
±±¿ƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
/*/

Static Function IMPCUS()                         
Local cQryCus:=""
//==============================================================================================================================================
//==================================Processamento dos dados Custo Social do Balanco Social===========================================================                                                                              
//==============================================================================================================================================
cQryCUS:=" SELECT RGN_ITEM,RGN_VLR1,RGN_VLR2"
cQryCUS+=" FROM "+RetSqlName("RGN")+" RGN "
cQryCUS+=" WHERE RGN_FILIAL = '"+cFilEmp+"' " 
cQryCUS+=" AND RGN_ANOBAS = '"+Alltrim(cAnoEmp)+"' " 
cQryCUS+=" AND RGN_PASTA = 'C' "
cQryCUS+=" AND D_E_L_E_T_='' "  

cQryCUS := ChangeQuery(cQryCUS)

If Select("TRBCUS")>0
	DbSelectArea("TRBCUS")
	TRBCUS->(DbCloseArea())
Endif

dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQryCUS),"TRBCUS",.F.,.T.)
If TRBCUS->(!Eof())
	Do While TRBCUS->(!Eof())
		If Alltrim(TRBCUS->RGN_ITEM)=="2.1" 
			nSalDir1:=TRBCUS->RGN_VLR1
			nSalDir2:=TRBCUS->RGN_VLR2 
			nTotal1+=nSalDir1
			nTotal2+=nSalDir2			
		ElseIf Alltrim(TRBCUS->RGN_ITEM)=="2.1.1"   
			nSalBas1:=TRBCUS->RGN_VLR1
			nSalBas2:=TRBCUS->RGN_VLR2
		ElseIf Alltrim(TRBCUS->RGN_ITEM)=="2.1.2"   
			nSubReg1:=TRBCUS->RGN_VLR1
			nSubReg2:=TRBCUS->RGN_VLR2
		ElseIf Alltrim(TRBCUS->RGN_ITEM)=="2.2"     
			nSubIrr1:=TRBCUS->RGN_VLR1
			nSubIrr2:=TRBCUS->RGN_VLR2
			nTotal1+=nSubIrr1
			nTotal2+=nSubirr2			
		ElseIf Alltrim(TRBCUS->RGN_ITEM)=="2.3"     
			nPagGen1:=TRBCUS->RGN_VLR1
			nPagGen2:=TRBCUS->RGN_VLR2
			nTotal1+=nPagGen1
			nTotal2+=nPagGen2			
		ElseIf Alltrim(TRBCUS->RGN_ITEM)=="2.4"     
			nEncarg1:=TRBCUS->RGN_VLR1
			nEncarg2:=TRBCUS->RGN_VLR2
			nTotal1+=nEncarg1
			nTotal2+=nEncarg2			
		ElseIf Alltrim(TRBCUS->RGN_ITEM)=="2.5"  
			nCusSoc1:=TRBCUS->RGN_VLR1
			nCusSoc2:=TRBCUS->RGN_VLR2
			nTotal1+=nCusSoc1
			nTotal2+=nCusSoc2			
		ElseIf Alltrim(TRBCUS->RGN_ITEM)=="2.6"     
			nCusFor1:=TRBCUS->RGN_VLR1
			nCusFor2:=TRBCUS->RGN_VLR2
			nTotal1+=nCusFor1
			nTotal2+=nCusFor2			
		ElseIf Alltrim(TRBCUS->RGN_ITEM)=="2.7"     
			nOCustP1:=TRBCUS->RGN_VLR1
			nOCustP2:=TRBCUS->RGN_VLR2
			nTotal1+=nOCustP1
			nTotal2+=nOCustP2			
		ElseIf Alltrim(TRBCUS->RGN_ITEM)=="2.9"
			nSalLiq:=TRBCUS->RGN_VLR1
		ElseIf Alltrim(TRBCUS->RGN_ITEM)=="2.10"
			nSalInt:=TRBCUS->RGN_VLR1
		Endif      
		TRBCUS->(DbSkip())
    End
Endif  

Return
/*/
‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±⁄ƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒø±±
±±≥Funcao    ≥IMPHIG ≥ Autor ≥ Marcos Kato              ≥ Data ≥ 12/07/07 ≥±±
±±≥ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥Descricao ≥Detalhe do Relatorio                                        ≥±±
±±√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥ Uso      ≥ Onsten                                                  	  ≥±±
±±¿ƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
/*/

Static Function IMPHIG()
Local cQryHS:=""                
Local nDoenca:=0

cQryHS:=" SELECT RGN_ITEM,RGN_SUBITE,RGN_DESCR,RGN_CODDOE,RGN_QTD1,RGN_VLR1"
cQryHS+=" FROM "+RetSqlName("RGN")+" RGN "
cQryHS+=" WHERE RGN_FILIAL = '"+cFilEmp+"' " 
cQryHS+=" AND RGN_ANOBAS = '"+ALLTRIM(cAnoEmp)+"' " 
cQryHS+=" AND RGN_PASTA = 'H' "
cQryHS+=" AND D_E_L_E_T_='' "  
cQryHS+=" ORDER BY RGN_ITEM, RGN_SUBITE "
cQryHS := ChangeQuery(cQryHS)

If Select("TRBHS")>0
	DbSelectArea("TRBHS")
	TRBHS->(DbCloseArea())
Endif

dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQryHS),"TRBHS",.F.,.T.)
If TRBHS->(!Eof())
	Do While TRBHS->(!Eof())
		cItem:=Alltrim(TRBHS->RGN_ITEM)
		cSubItem:=Alltrim(TRBHS->RGN_SUBITE)
        If cItem=="3.1.2" .and. cSubItem=="0902"//N∞Acidentes com Baixa(1 a 3 dias de baixas)
          	aListHS[1]:=TRBHS->RGN_QTD1
        ElseIf cItem=="3.1.3" .and. cSubItem=="0902"//N∞de dias perdidos com baixa(1 a 3 dias de baixas)
           	aListHS[2]:=TRBHS->RGN_QTD1
	   	ElseIf cItem=="3.1.2" .and. cSubItem=="0907"//N∞Acidentes com Baixa(1 a 3 dias de baixas)
           	aListHS[3]:=TRBHS->RGN_QTD1 
	    ElseIf cItem=="3.1.3" .and. cSubItem=="0907"//N∞de dias perdidos com baixa(1 a 3 dias de baixas)
           	aListHS[4]:=TRBHS->RGN_QTD1 
	    ElseIf cItem=="3.1.2" .and. cSubItem=="0903"//N∞Acidentes com Baixa(4 a 30 dias de baixas)
           	aListHS[5]:=TRBHS->RGN_QTD1
	    ElseIf cItem=="3.1.3" .and. cSubItem=="0903"//N∞de dias perdidos com baixa(4 a 30 dias de baixas)
           	aListHS[6]:=TRBHS->RGN_QTD1
	    ElseIf cItem=="3.1.2" .and. cSubItem=="0908"//N∞Acidentes com Baixa(4 a 30 dias de baixas)
           	aListHS[7]:=TRBHS->RGN_QTD1
	    ElseIf cItem=="3.1.3" .and. cSubItem=="0908"//N∞de dias perdidos com baixa(4 a 30 dias de baixas)
           	aListHS[8]:=TRBHS->RGN_QTD1
	    ElseIf cItem=="3.1.4" .and. cSubItem=="0904"//N∞Acidentes com Baixa(mais de 30 dias de baixas)
           	aListHS[9]:=TRBHS->RGN_QTD1
	    ElseIf cItem=="3.1.1" .and. cSubItem=="0904"//N∞de dias perdidos com baixa(mais de 30 dias de baixas)
           	aListHS[10]:=TRBHS->RGN_QTD1
	    ElseIf cItem=="3.1.2" .and. cSubItem=="0909"//N∞Acidentes com Baixa(mais de 30 dias de baixas)
           	aListHS[11]:=TRBHS->RGN_QTD1
	    ElseIf cItem=="3.1.3" .and. cSubItem=="0909"//N∞de dias perdidos com baixa(mais de 30 dias de baixas)
           	aListHS[12]:=TRBHS->RGN_QTD1
	    ElseIf cItem=="3.1.4" .and. cSubItem=="0905"//N∞Total de acidentes(Mortais)
           	aListHS[13]:=TRBHS->RGN_QTD1
	    ElseIf cItem=="3.1.5" .and. cSubItem=="0910"//N∞Total de acidentes(Mortais)
           	aListHS[14]:=TRBHS->RGN_QTD1               
	    ElseIf cItem=="3.1.4"//N∞ de casos de incapacidade permanente declarados no ano
           	aListHS[21]:=TRBHS->RGN_QTD1
	    ElseIf cItem=="3.1.4.1"//N∞ de casos de incapacidade permanente absoluta
           	aListHS[22]:=TRBHS->RGN_QTD1
	    ElseIf cItem=="3.1.4.2"//N∞ de casos de incapacidade permanente parcial
           	aListHS[23]:=TRBHS->RGN_QTD1	        
		ElseIf cItem=="3.2"      
		    If !EMPTY(TRBHS->RGN_DESCR) .OR. !EMPTY(TRBHS->RGN_CODDOE)	
				nDoenca++
				aListEmp2[3][nDoenca][1]:=TRBHS->RGN_DESCR
				aListEmp2[3][nDoenca][2]:=TRBHS->RGN_CODDOE
				aListEmp2[3][nDoenca][3]:=TRBHS->RGN_QTD1
			Endif
	    ElseIf cItem=="3.3.1.1"//Exames de Admissao
           	aListHS[24]:=TRBHS->RGN_QTD1	        
	    ElseIf cItem=="3.3.1.2"//Exames Periodicos
           	aListHS[25]:=TRBHS->RGN_QTD1	        
	    ElseIf cItem=="3.3.1.3"//Exames Ocasionais e Complementares
           	aListHS[26]:=TRBHS->RGN_QTD1	        
	    ElseIf cItem=="3.3.1"//Total de Exames Efetuados
           	aListHS[27]:=TRBHS->RGN_QTD1	        
	    ElseIf cItem=="3.3.2"//N∞ de visitas efetuadas aos postos de Trabalho
           	aListHS[28]:=TRBHS->RGN_QTD1	        
	    ElseIf cItem=="3.3.3"//Desp.Medicina de Trabalho
           	aListHS[29]:=TRBHS->RGN_QTD1	        
	    ElseIf cItem=="3.4.1"//Reunioes Anuais de Higiene e Seguranca(Comissoes de Higiene e seguranca)
           	aListHS[30]:=TRBHS->RGN_QTD1	        
	    ElseIf cItem=="3.4.2"//Visitas aos Locais de Trabalho(Comissoes de Higiene e seguranca)
           	aListHS[31]:=TRBHS->RGN_QTD1	        
	    ElseIf cItem=="3.5.1"//N∞ de Pessoas(Acoes de Segurancae Sensibilizacao de acidente de trabalho)
           	aListHS[32]:=TRBHS->RGN_QTD1	        
	    ElseIf cItem=="3.6.1"//N∞de acoes desenvolvidas
           	aListHS[33]:=TRBHS->RGN_QTD1	        
	    ElseIf cItem=="3.6.2"//N∞ de pessoas abrangidas pela acao
           	aListHS[34]:=TRBHS->RGN_QTD1	        
	    ElseIf cItem=="3.7.1"//Encargos da Estrutura da Medicina de Trabalho e seguranca
           	aListHS[35]:=TRBHS->RGN_VLR1	        
	    ElseIf cItem=="3.7.2"//Custos com equipamento de protecao
           	aListHS[36]:=TRBHS->RGN_VLR1	        
	    ElseIf cItem=="3.7.3"//Custos com Formacao e Prevencao
           	aListHS[37]:=TRBHS->RGN_VLR1	        
	    ElseIf cItem=="3.7.4"//Outros Custos
           	aListHS[38]:=TRBHS->RGN_VLR1
        Endif
        TRBHS->(DbSkip())
	End
	//Totalizadores  
	aListHS[15]:=aListHS[13]
	aListHS[16]:=aListHS[1]+aListHS[5]+aListHS[9]
	aListHS[17]:=aListHS[2]+aListHS[6]+aListHS[10]
	aListHS[18]:=aListHS[14]
	aListHS[19]:=aListHS[3]+aListHS[7]+aListHS[11]
	aListHS[20]:=aListHS[4]+aListHS[8]+aListHS[12]
Endif	

Return
/*/
‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±⁄ƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒø±±
±±≥Funcao    ≥RGERBS ≥ Autor ≥ Marcos Kato              ≥ Data ≥ 12/07/07 ≥±±
±±≥ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥Descricao ≥Detalhe do Relatorio                                        ≥±±
±±√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥ Uso      ≥ Onsten                                                  	  ≥±±
±±¿ƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
/*/

Static Function IMPFOR()
Local cQryFP:=""
Local cItem :="" 
Local nH0100:=0,nH0249:=0,nH0499:=0,nH0999:=0,nH1000:=0,nVlrFp:=0              
Local nDir  :=0,nQSup :=0,nQMed :=0,nQInt :=0,nPAQ  :=0,nPSQ  :=0,nPNQ  :=0,nPAp :=0


cQryFP:=" SELECT RGN_ITEM,RGN_SUBITE,RGN_QTD1,RGN_VLR1"
cQryFP+=" FROM "+RetSqlName("RGN")+" RGN "
cQryFP+=" WHERE RGN_FILIAL = '"+cFilEmp+"' " 
cQryFP+=" AND RGN_ANOBAS = '"+ALLTRIM(cAnoEmp)+"' " 
cQryFP+=" AND RGN_PASTA = 'P' "
cQryFP+=" AND D_E_L_E_T_='' "  
cQryFP+=" ORDER BY RGN_ITEM, RGN_SUBITE "
cQryFP := ChangeQuery(cQryFP)

If Select("TRBFP")>0
	DbSelectArea("TRBFP")
	TRBFP->(DbCloseArea())
Endif

dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQryFP),"TRBFP",.F.,.T.)
If TRBFP->(!Eof())
	Do While TRBFP->(!Eof())
		cItem:=Alltrim(TRBFP->RGN_ITEM)
		Do While TRBFP->(!Eof()) .And. cItem==Alltrim(TRBFP->RGN_ITEM)//Numero Total das Acoes
			If Alltrim(TRBFP->RGN_SUBITE)=="0801"//Menos de 100 Horas
				nH0100:=TRBFP->RGN_QTD1
			ElseIf Alltrim(TRBFP->RGN_SUBITE)=="0802"//De 100 a 249 Horas
				nH0249:=TRBFP->RGN_QTD1
			ElseIf Alltrim(TRBFP->RGN_SUBITE)=="0803"//De 250 a 499 Horas 
				nH0499:=TRBFP->RGN_QTD1
			ElseIf Alltrim(TRBFP->RGN_SUBITE)=="0804"//De 500 a 999 Horas
				nH0999:=TRBFP->RGN_QTD1
			ElseIf Alltrim(TRBFP->RGN_SUBITE)=="0805"//Mais de 1000 Horas
				nH1000:=TRBFP->RGN_QTD1
			ElseIf Alltrim(TRBFP->RGN_SUBITE)=="0101"//Dirigente
				nDir  :=TRBFP->RGN_QTD1
			ElseIf Alltrim(TRBFP->RGN_SUBITE)=="0102"//Quadro Superior
				nQSup:=TRBFP->RGN_QTD1
			ElseIf Alltrim(TRBFP->RGN_SUBITE)=="0103"//Quadro Medio
				nQMed:=TRBFP->RGN_QTD1 
			ElseIf Alltrim(TRBFP->RGN_SUBITE)=="0104"//Quadro Intermediario
				nQInt:=TRBFP->RGN_QTD1 				 
			ElseIf Alltrim(TRBFP->RGN_SUBITE)=="0105"//Profissional Altamente qualificado e qualificado
				nPAQ :=TRBFP->RGN_QTD1 
			ElseIf Alltrim(TRBFP->RGN_SUBITE)=="0106"//Profissional Semiqualificado
				nPSQ :=TRBFP->RGN_QTD1 
			ElseIf Alltrim(TRBFP->RGN_SUBITE)=="0107"//Profissional nao qualificado
				nPNQ :=TRBFP->RGN_QTD1 
			ElseIf Alltrim(TRBFP->RGN_SUBITE)=="0108"//Praticante/Aprendiz
				nPAp :=TRBFP->RGN_QTD1
			Endif
			nVlrFP:=TRBFP->RGN_VLR1
			TRBFP->(DbSkip())
		End
		If Alltrim(cItem)=="4.1"//Numero total das acoes     	            
			aListFP[1][1]:=nH0100
			aListFP[1][2]:=nH0249
			aListFP[1][3]:=nH0499
			aListFP[1][4]:=nH0999
			aListFP[1][5]:=nH1000
		ElseIf Alltrim(cItem)=="4.1.1"//Numero de acoes internas
			aListFP[2][1]:=nH0100
			aListFP[2][2]:=nH0249
			aListFP[2][3]:=nH0499
			aListFP[2][4]:=nH0999
			aListFP[2][5]:=nH1000
		ElseIf Alltrim(cItem)=="4.1.2"//Numero de acoes externas
			aListFP[3][1]:=nH0100
			aListFP[3][2]:=nH0249
			aListFP[3][3]:=nH0499
			aListFP[3][4]:=nH0999
			aListFP[3][5]:=nH1000
		ElseIf Alltrim(cItem)=="4.2"//Numero total de participantes    	            
			nTot:=nDir+nQSup+nQMed+nQInt+nPAQ+nPSQ+nPNQ+nPAp
			aListFP[4][1]:=nDir
			aListFP[4][2]:=nQSup
			aListFP[4][3]:=nQMed
			aListFP[4][4]:=nQInt
			aListFP[4][5]:=nPAQ
			aListFP[4][6]:=nPSQ
			aListFP[4][7]:=nPNQ
			aListFP[4][8]:=nPAp
			aListFP[4][9]:=nTot
		ElseIf Alltrim(cItem)=="4.2.1"//Numero de participantes de acoes internas
			nTot:=nDir+nQSup+nQMed+nQInt+nPAQ+nPSQ+nPNQ+nPAp
			aListFP[5][1]:=nDir
			aListFP[5][2]:=nQSup
			aListFP[5][3]:=nQMed
			aListFP[5][4]:=nQInt
			aListFP[5][5]:=nPAQ
			aListFP[5][6]:=nPSQ
			aListFP[5][7]:=nPNQ
			aListFP[5][8]:=nPAp
			aListFP[5][9]:=nTot
		ElseIf Alltrim(cItem)=="4.2.2"//Numero de participantes de acoes externas
			nTot:=nDir+nQSup+nQMed+nQInt+nPAQ+nPSQ+nPNQ+nPAp
			aListFP[6][1]:=nDir
			aListFP[6][2]:=nQSup
			aListFP[6][3]:=nQMed
			aListFP[6][4]:=nQInt
			aListFP[6][5]:=nPAQ
			aListFP[6][6]:=nPSQ
			aListFP[6][7]:=nPNQ
			aListFP[6][8]:=nPAp
			aListFP[6][9]:=nTot
		ElseIf Alltrim(cItem)=="4.3"//Numero Total de Horas	            
			nTot:=nDir+nQSup+nQMed+nQInt+nPAQ+nPSQ+nPNQ+nPAp
			aListFP[7][1]:=nDir
			aListFP[7][2]:=nQSup
			aListFP[7][3]:=nQMed
			aListFP[7][4]:=nQInt
			aListFP[7][5]:=nPAQ
			aListFP[7][6]:=nPSQ
			aListFP[7][7]:=nPNQ
			aListFP[7][8]:=nPAp
			aListFP[7][9]:=nTot
		ElseIf Alltrim(cItem)=="4.3.1"//Numero de Horas de acoes internas
			nTot:=nDir+nQSup+nQMed+nQInt+nPAQ+nPSQ+nPNQ+nPAp
			aListFP[8][1]:=nDir
			aListFP[8][2]:=nQSup
			aListFP[8][3]:=nQMed
			aListFP[8][4]:=nQInt
			aListFP[8][5]:=nPAQ
			aListFP[8][6]:=nPSQ
			aListFP[8][7]:=nPNQ
			aListFP[8][8]:=nPAp
			aListFP[8][9]:=nTot
		ElseIf Alltrim(cItem)=="4.3.2"//Numero de Horas de acoes externas
			nTot:=nDir+nQSup+nQMed+nQInt+nPAQ+nPSQ+nPNQ+nPAp
			aListFP[9][1]:=nDir
			aListFP[9][2]:=nQSup
			aListFP[9][3]:=nQMed
			aListFP[9][4]:=nQInt
			aListFP[9][5]:=nPAQ
			aListFP[9][6]:=nPSQ
			aListFP[9][7]:=nPNQ
			aListFP[9][8]:=nPAp
			aListFP[9][9]:=nTot
		ElseIf Alltrim(cItem)=="4.4.1"//Custos Totais de formacao      
			aListFP[10][1]:=nVlrFp
		ElseIf Alltrim(cItem)=="4.4.2"//Custos em acoes internas
			aListFP[11][1]:=nVlrFp
		ElseIf Alltrim(cItem)=="4.4.3"//Custos em acoes externas
			aListFP[12][1]:=nVlrFp
		Endif
		//Zerando os valores das variaveis
		nH0100:=0
		nH0249:=0
		nH0499:=0
		nH0999:=0
		nH1000:=0              
		nDir  :=0
		nQSup :=0
		nQMed :=0
		nQInt :=0
		nPAQ  :=0
		nPSQ  :=0
		nPNQ  :=0
		nPAp  :=0
	End
Endif	

Return

/*/
‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±⁄ƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒø±±
±±≥Funcao    ≥IMPPRO ≥ Autor ≥ Marcos Kato              ≥ Data ≥ 12/07/07 ≥±±
±±≥ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥Descricao ≥Detalhe do Relatorio                                        ≥±±
±±√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥ Uso      ≥ Onsten                                                  	  ≥±±
±±¿ƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
/*/
Static Function IMPPRO()
Local cQryPRO :=""
//==============================================================================================================================================
//==================================Processando dados Protecao Social Complementar do Balanco Social============================================
//==============================================================================================================================================
cQryPRO:=" SELECT RGN_ITEM,RGN_QTD1,RGN_VLR1 "
cQryPRO+=" FROM "+RetSqlName("RGN")+" RGN "
cQryPRO+=" WHERE RGN_FILIAL = '"+cFilEmp+"' " 
cQryPRO+=" AND RGN_ANOBAS = '"+ALLTRIM(cAnoEmp)+"' " 
cQryPRO+=" AND RGN_PASTA = 'S' "
cQryPRO+=" AND D_E_L_E_T_='' "  
cQryPRO+=" ORDER BY RGN_ITEM "

cQryPRO := ChangeQuery(cQryPRO)

If Select("TRBPRO")>0
	DbSelectArea("TRBPRO")
	TRBPRO->(DbCloseArea())
Endif

dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQryPRO),"TRBPRO",.F.,.T.)
If TRBPRO->(!Eof())
	Do While TRBPRO->(!Eof())
		If Alltrim(TRBPRO->RGN_ITEM)=="5.1.1"//Complementos de Subsidio por doenca e doenca profissional(Prestacoes)
			nEdPsc1:=TRBPRO->RGN_QTD1
			nEdPsc2:=TRBPRO->RGN_VLR1
		ElseIf Alltrim(TRBPRO->RGN_ITEM)=="5.1.2"//Complementos de pensoes de velhice, de invalidez e de sobrevivencia(Prestacoes)
			nEdPsc3:=TRBPRO->RGN_QTD1
			nEdPsc4:=TRBPRO->RGN_VLR1
		ElseIf Alltrim(TRBPRO->RGN_ITEM)=="5.1.3"//Complementos de outras prestacoes de seguranca social(Prestacoes)
			nEdPsc5:=TRBPRO->RGN_QTD1
			nEdPsc6:=TRBPRO->RGN_VLR1
		ElseIf Alltrim(TRBPRO->RGN_ITEM)=="5.2.1"//Complementos de Subsidio por doenca e doenca profissional(Premios)
			nEdPsc7:=TRBPRO->RGN_QTD1
			nEdPsc8:=TRBPRO->RGN_VLR1
		ElseIf Alltrim(TRBPRO->RGN_ITEM)=="5.2.2"//Complementos de pensoes de velhice, de invalidez e de sobrevivencia(Premios)	
			nEdPsc9:=TRBPRO->RGN_QTD1
			nEdPsc10:=TRBPRO->RGN_VLR1
		ElseIf Alltrim(TRBPRO->RGN_ITEM)=="5.2.3"//Complementos de pensoes de velhice, de invalidez e de sobrevivencia(Premios)	
			nEdPsc11:=TRBPRO->RGN_QTD1
			nEdPsc12:=TRBPRO->RGN_VLR1
		ElseIf Alltrim(TRBPRO->RGN_ITEM)=="5.3.1"//Apoio a Infancia
			nEdPsc13:=TRBPRO->RGN_VLR1
		ElseIf Alltrim(TRBPRO->RGN_ITEM)=="5.3.2"//Apoio a idosos
			nEdPsc14:=TRBPRO->RGN_VLR1
		ElseIf Alltrim(TRBPRO->RGN_ITEM)=="5.3.3"//Apoio a tempo livres
			nEdPsc15:=TRBPRO->RGN_VLR1
		ElseIf Alltrim(TRBPRO->RGN_ITEM)=="5.3.4"//Outros apoios
			nEdPsc16:=TRBPRO->RGN_VLR1                          
		ElseIf Alltrim(TRBPRO->RGN_ITEM)=="5.4.1"//Grupos desportivos/casa de pessoal
			nEdPsc17:=TRBPRO->RGN_VLR1    		
		ElseIf Alltrim(TRBPRO->RGN_ITEM)=="5.4.2"//alimentacao
			nEdPsc18:=TRBPRO->RGN_VLR1    		
		ElseIf Alltrim(TRBPRO->RGN_ITEM)=="5.4.3"//Apoio a estudos
			nEdPsc19:=TRBPRO->RGN_VLR1    		
		ElseIf Alltrim(TRBPRO->RGN_ITEM)=="5.4.4"//Saude
			nEdPsc20:=TRBPRO->RGN_VLR1    		
		ElseIf Alltrim(TRBPRO->RGN_ITEM)=="5.4.5"//Habitacao
			nEdPsc21:=TRBPRO->RGN_VLR1    		
		ElseIf Alltrim(TRBPRO->RGN_ITEM)=="5.4.6"//Transportes
			nEdPsc22:=TRBPRO->RGN_VLR1    		
		ElseIf Alltrim(TRBPRO->RGN_ITEM)=="5.4.7"//Seguros especiais
			nEdPsc23:=TRBPRO->RGN_VLR1    		
		ElseIf Alltrim(TRBPRO->RGN_ITEM)=="5.4.8"//Adiantamento e emprestimos
			nEdPsc24:=TRBPRO->RGN_VLR1    		
		ElseIf Alltrim(TRBPRO->RGN_ITEM)=="5.4.9"//Outros apoios
			nEdPsc25:=TRBPRO->RGN_VLR1    		
        Endif
    	TRBPRO->(DbSkip())
    End
Endif
Return

/*/
‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±⁄ƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒø±±
±±≥Funcao    ≥RGERBS ≥ Autor ≥ Marcos Kato              ≥ Data ≥ 12/07/07 ≥±±
±±≥ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥Descricao ≥Detalhe do Relatorio                                        ≥±±
±±√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥ Uso      ≥ Onsten                                                  	  ≥±±
±±¿ƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
/*/

Static Function IMPGER()
Local nCont1,nCont2,nCnt
Private nSalDir1	 := 0,nSalDir2	 := 0,nSalBas1	 := 0,nSalBas2	 := 0
Private nSubReg1	 := 0,nSubReg2	 := 0,nSubIrr1	 := 0,nSubIrr2	 := 0
Private nPagGen1	 := 0,nPagGen2	 := 0,nEncarg1	 := 0,nEnCarg2	 := 0
Private nCusSoc1	 := 0,nCusSoc2	 := 0,nCusFor1	 := 0,nCusFor2	 := 0
Private nOCustP1	 := 0,nOCustP2	 := 0,nTotal1	 := 0,nTotal2	 := 0
Private nSalLiq	 := 0,nSalInt	 := 0
Private aListHS:=ARRAY(38)  //Higiene e Seguranca
Private aListFP:=ARRAY(12,9)//Formacao Profissional

Private nEdPsc1 := 0,nEdPsc2 := 0,nEdPsc3 := 0,nEdPsc4 := 0,nEdPsc5 := 0,nEdPsc6 := 0,nEdPsc7 := 0,nEdPsc8 := 0
Private nEdPsc9 := 0,nEdPsc10:= 0,nEdPsc11:= 0,nEdPsc12:= 0,nEdPsc13:= 0,nEdPsc14:= 0,nEdPsc15:= 0,nEdPsc16:= 0
Private nEdPsc17:= 0,nEdPsc18:= 0,nEdPsc19:= 0,nEdPsc20:= 0,nEdPsc21:= 0,nEdPsc22:= 0,nEdPsc23:= 0,nEdPsc24:= 0
Private nEdPsc25:= 0

For nCont1:=1 To 38
	aListHS[nCont1]:=0
Next

For nCont1:=1 To 12
	For nCont2:=1 To 9
		aListFP[nCont1][nCont2]	:=0
	Next
Next


MsgRun(STR0008,STR0004, {||CursorWait(),IMPCUS(),CursorArrow()})//Gerando dados do Custo Social#Aguarde...
MsgRun(STR0009,STR0004, {||CursorWait(),IMPHIG(),CursorArrow()})//Gerando dados da Higiene e Seguranca #Aguarde...
MsgRun(STR0010,STR0004, {||CursorWait(),IMPFOR(),CursorArrow()})//Gerando dados da Formacao Profissional#Aguarde...
MsgRun(STR0011,STR0004, {||CursorWait(),IMPPRO(),CursorArrow()})//Gerando dados da Protecao Social Complementar  #Aguarde...
//=================================================================================================================================================
//PAGINA 08========================================================================================================================================
//=================================================================================================================================================
oPrint:StartPage() 		// Inicia uma nova pagina		
oPrint:Saybitmap(010,010,cStartPath+"BS08"+".bmp",2500,3400)  
nLin:=620 
nCol:=600

//=========================================================================================
//==================================CUSTOS COM PESSOAL===================================== 
//=========================================================================================
//Salario Direto
oPrint:Say(nLin,nCol+940     	,Space(14-Len(Alltrim(Str(nSalDir1))))+Transform(nSalDir1,"@E 999,999,999.99"),oArial14N)
oPrint:Say(nLin,nCol+1340	    ,Space(14-Len(Alltrim(Str(nSalDir2))))+Transform(nSalDir2,"@E 999,999,999.99"),oArial14N)
nLin+=70
//Salario Base
oPrint:Say(nLin,nCol+940      	,Space(14-Len(Alltrim(Str(nSalBas1))))+Transform(nSalBas1,"@E 999,999,999.99"),oArial14N)
oPrint:Say(nLin,nCol+1340	    ,Space(14-Len(Alltrim(Str(nSalBas2))))+Transform(nSalBas2,"@E 999,999,999.99"),oArial14N)
nLin+=70
//Subsidio Regular                      
oPrint:Say(nLin,nCol+940     	,Space(14-Len(Alltrim(Str(nSubReg1))))+Transform(nSubReg1,"@E 999,999,999.99"),oArial14N)
oPrint:Say(nLin,nCol+1340	    ,Space(14-Len(Alltrim(Str(nSubReg2))))+Transform(nSubReg2,"@E 999,999,999.99"),oArial14N)
nLin+=70
//Subsidio Irregular
oPrint:Say(nLin,nCol+940      	,Space(14-Len(Alltrim(Str(nSubIrr1))))+Transform(nSubIrr1,"@E 999,999,999.99"),oArial14N)
oPrint:Say(nLin,nCol+1340	    ,Space(14-Len(Alltrim(Str(nSubIrr2))))+Transform(nSubIrr2,"@E 999,999,999.99"),oArial14N)
nLin+=70
//Pagamento Generos
oPrint:Say(nLin,nCol+940      	,Space(14-Len(Alltrim(Str(nPagGen1))))+Transform(nPagGen1,"@E 999,999,999.99"),oArial14N)
oPrint:Say(nLin,nCol+1340	    ,Space(14-Len(Alltrim(Str(nPagGen2))))+Transform(nPagGen2,"@E 999,999,999.99"),oArial14N)
nLin+=70
//Encargos                              
oPrint:Say(nLin,nCol+940      	,Space(14-Len(Alltrim(Str(nEncarg1))))+Transform(nEncarg1,"@E 999,999,999.99"),oArial14N)
oPrint:Say(nLin,nCol+1340	    ,Space(14-Len(Alltrim(Str(nEncarg2))))+Transform(nEncarg2,"@E 999,999,999.99"),oArial14N)
nLin+=70
//Outros Custos de Carater Social
oPrint:Say(nLin,nCol+940      	,Space(14-Len(Alltrim(Str(nCusSoc1))))+Transform(nCusSoc1,"@E 999,999,999.99"),oArial14N)
oPrint:Say(nLin,nCol+1340	    ,Space(14-Len(Alltrim(Str(nCusSoc2))))+Transform(nCusSoc2,"@E 999,999,999.99"),oArial14N)
nLin+=70
//Custos com a formacao profissional
oPrint:Say(nLin,nCol+940	   	,Space(14-Len(Alltrim(Str(nCusFor1))))+Transform(nCusFor1,"@E 999,999,999.99"),oArial14N)
oPrint:Say(nLin,nCol+1340	    ,Space(14-Len(Alltrim(Str(nCusFor2))))+Transform(nCusFor2,"@E 999,999,999.99"),oArial14N)
nLin+=70
//Outros Custos com o pessoal
oPrint:Say(nLin,nCol+940      	,Space(14-Len(Alltrim(Str(nOCustP1))))+Transform(nOCustP1,"@E 999,999,999.99"),oArial14N)
oPrint:Say(nLin,nCol+1340	    ,Space(14-Len(Alltrim(Str(nOCustP2))))+Transform(nOCustP2,"@E 999,999,999.99"),oArial14N)
nLin+=70
//Total
oPrint:Say(nLin,nCol+940      	,Space(14-Len(Alltrim(Str(nTotal1))))+Transform(nTotal1,"@E 999,999,999.99"),oArial14N)
oPrint:Say(nLin,nCol+1340	    ,Space(14-Len(Alltrim(Str(nTotal2))))+Transform(nTotal2,"@E 999,999,999.99"),oArial14N)
nLin+=210
//Leque salarial liquido

oPrint:Say(nLin,nCol+1340   ,Space(14-Len(Alltrim(Str(nSalliq))))+Transform(nSalLiq ,"@E 999,999,999.99"),oArial14N)
nLin+=100
//Leque salarial interpretativo

oPrint:Say(nLin,nCol+1340   ,Space(14-Len(Alltrim(Str(nSalInt))))+Transform(nSalInt ,"@E 999,999,999.99"),oArial14N)
//=========================================================================================
//================================HIGIENE E SEGURANCA====================================== 
//=========================================================================================
//**********************************************************************************************************************************
//ACIDENTES DE TRABALHO
//**********************************************************************************************************************************
//=================================================================
//N∞Total de acidentes
//=================================================================
nLin+=800
//////////////////////
//Local de Trabalho //
//////////////////////                                                                                                    
//N∞Total de acidentes(Total)
oPrint:Say(nLin,nCol-60  	,Space(6-Len(Alltrim(Str(aListHS[13]))))+Transform(aListHS[13],"@E 999999")        ,oArial14N)
//N∞Total de acidentes(Mortais)
oPrint:Say(nLin,nCol+660  	,Space(6-Len(Alltrim(Str(aListHS[13]))))+Transform(aListHS[13],"@E 999999")        ,oArial14N)
//////////////////////
//Intinere          //
//////////////////////
//N∞Total de acidentes(Total)
oPrint:Say(nLin,nCol+860  	,Space(6-Len(Alltrim(Str(aListHS[14]))))+Transform(aListHS[14],"@E 999999")        ,oArial14N)
//N∞Total de acidentes(Mortais)
oPrint:Say(nLin,nCol+1580  	,Space(6-Len(Alltrim(Str(aListHS[14]))))+Transform(aListHS[14],"@E 999999")        ,oArial14N)
//=================================================================
//N∞Acidentes com Baixa
//=================================================================
nLin+=120
//////////////////////
//Local de Trabalho //
//////////////////////
//N∞Acidentes com Baixa(Total)
oPrint:Say(nLin,nCol-60   	  	,Space(6-Len(Alltrim(Str(aListHS[1]+aListHS[5]+aListHS[9]))))+Transform(aListHS[1]+aListHS[5]+aListHS[9],"@E 999999")        ,oArial14N)
//N∞Acidentes com Baixa(1 a 3 dias de baixas)
oPrint:Say(nLin,nCol+120   	  	,Space(6-Len(Alltrim(Str(aListHS[1]))))+Transform(aListHS[1],"@E 999999")        ,oArial14N)
//N∞Acidentes com Baixa(4 a 30 dias de baixas)
oPrint:Say(nLin,nCol+300   	  	,Space(6-Len(Alltrim(Str(aListHS[5]))))+Transform(aListHS[5],"@E 999999")        ,oArial14N)
//N∞Acidentes com Baixa(mais de 30 dias de baixas)
oPrint:Say(nLin,nCol+480   	  	,Space(6-Len(Alltrim(Str(aListHS[9]))))+Transform(aListHS[9],"@E 999999")        ,oArial14N)
//////////////////////
//Intinere          //
//////////////////////
//N∞Acidentes com Baixa(Total)
oPrint:Say(nLin,nCol+860  	  	,Space(6-Len(Alltrim(Str(aListHS[3]+aListHS[7]+aListHS[11]))))+Transform(aListHS[3]+aListHS[7]+aListHS[11],"@E 999999")        ,oArial14N)
//N∞Acidentes com Baixa(1 a 3 dias de baixas)
oPrint:Say(nLin,nCol+1040   	  	,Space(6-Len(Alltrim(Str(aListHS[3]))))+Transform(aListHS[3],"@E 999999")        ,oArial14N)
//N∞Acidentes com Baixa(4 a 30 dias de baixas)
oPrint:Say(nLin,nCol+1220   	  	,Space(6-Len(Alltrim(Str(aListHS[7]))))+Transform(aListHS[7],"@E 999999")        ,oArial14N)
//N∞Acidentes com Baixa(mais de 30 dias de baixas)
oPrint:Say(nLin,nCol+1400   	  	,Space(6-Len(Alltrim(Str(aListHS[11]))))+Transform(aListHS[11],"@E 999999")        ,oArial14N)
//=================================================================
//N∞de Dias Perdidos com Baixa
//=================================================================
nLin+=120           
//////////////////////
//Local de Trabalho //
//////////////////////
//N∞de dias perdidos com baixa(Total)
oPrint:Say(nLin,nCol-60   	  	,Space(6-Len(Alltrim(Str(aListHS[2]+aListHS[6]+aListHS[10]))))+Transform(aListHS[2]+aListHS[6]+aListHS[10],"@E 999999")        ,oArial14N)
//N∞de dias perdidos com baixa(1 a 3 dias de baixas)
oPrint:Say(nLin,nCol+120   	  		,Space(6-Len(Alltrim(Str(aListHS[2]))))+Transform(aListHS[2],"@E 999999")        ,oArial14N)
//N∞de dias perdidos com baixa(4 a 30 dias de baixas)
oPrint:Say(nLin,nCol+300 	  	,Space(6-Len(Alltrim(Str(aListHS[6]))))+Transform(aListHS[6],"@E 999999")        ,oArial14N)
//N∞de dias perdidos com baixa(mais de 30 dias de baixas)
oPrint:Say(nLin,nCol+480   	  	,Space(6-Len(Alltrim(Str(aListHS[10]))))+Transform(aListHS[10],"@E 999999")        ,oArial14N)
//////////////////////
//Intinere          //
//////////////////////
//N∞de dias perdidos com baixa(Total)
oPrint:Say(nLin,nCol+860   	  	,Space(6-Len(Alltrim(Str(aListHS[4]+aListHS[8]+aListHS[12]))))+Transform(aListHS[4]+aListHS[8]+aListHS[12],"@E 999999")        ,oArial14N)
//N∞de dias perdidos com baixa(1 a 3 dias de baixas)
oPrint:Say(nLin,nCol+1040   	,Space(6-Len(Alltrim(Str(aListHS[4]))))+Transform(aListHS[4],"@E 999999")        ,oArial14N)
//N∞de dias perdidos com baixa(4 a 30 dias de baixas)
oPrint:Say(nLin,nCol+1220   	  	,Space(6-Len(Alltrim(Str(aListHS[8]))))+Transform(aListHS[8],"@E 999999")        ,oArial14N)
//N∞de dias perdidos com baixa(mais de 30 dias de baixas)
oPrint:Say(nLin,nCol+1400   	  	,Space(6-Len(Alltrim(Str(aListHS[12]))))+Transform(aListHS[12],"@E 999999")        ,oArial14N)
nLin+=220                     
//=================================================================
//N∞ de casos de incapacidade permanente declarados no ano
//=================================================================
oPrint:Say(nLin,nCol+1560   	  	,Space(6-Len(Alltrim(Str(aListHS[21]))))+Transform(aListHS[21],"@E 999999")        ,oArial14N)
//=================================================================
//N∞ de casos de incapacidade permanente absoluta
//=================================================================
nLin+=120               
oPrint:Say(nLin,nCol+1560   	  	,Space(6-Len(Alltrim(Str(aListHS[22]))))+Transform(aListHS[22],"@E 999999")        ,oArial14N)
//=================================================================
//N∞ de casos de incapacidade permanente parcial
//=================================================================
nLin+=120               
oPrint:Say(nLin,nCol+1560   	  	,Space(6-Len(Alltrim(Str(aListHS[23]))))+Transform(aListHS[23],"@E 999999")        ,oArial14N)
oPrint:EndPage() 		// Finaliza a pagina
//=================================================================================================================================================
//PAGINA 09========================================================================================================================================
//=================================================================================================================================================
oPrint:StartPage() 		// Inicia uma nova pagina		
oPrint:Saybitmap(010,010,cStartPath+"BS09"+".bmp",2500,3400)  

nCol:=400              
//**********************************************************************************************************************************
//ATIVIDADE DA MEDICINA DO TRABALHO
//**********************************************************************************************************************************
nLin:=280
nCol:=1400
For nCnt:=1 To 12                                    
	If !Empty(Alltrim(aListEmp2[3][nCnt][1]))
		oPrint:Say(nLin,200	   	  		,Alltrim(aListEmp2[3][nCnt][1])																	      	,oArial14N)
		oPrint:Say(nLin,nCol+500   	  	,Alltrim(aListEmp2[3][nCnt][2])       																	,oArial14N)
		oPrint:Say(nLin,nCol+690   	  	,Space(6-Len(Alltrim(Str(aListEmp2[3][nCnt][3]))))+Transform(aListEmp2[3][nCnt][3],"@E 999999")        	,oArial14N)
	Endif
	nLin+=70
Next				
//=================================================================
//Exames de Admissao
//=================================================================
nLin:=1400 
nLin+=270                                                          
oPrint:Say(nLin,nCol+690   	  	,Space(6-Len(Alltrim(Str(aListHS[24]))))+Transform(aListHS[24],"@E 999999")        ,oArial14N)
//=================================================================
//Exames Periodicos
//=================================================================
nLin+=80
oPrint:Say(nLin,nCol+690   	  	,Space(6-Len(Alltrim(Str(aListHS[25]))))+Transform(aListHS[25],"@E 999999")        ,oArial14N)
//=================================================================
//Exames Ocasionais e Complementares
//=================================================================
nLin+=70
oPrint:Say(nLin,nCol+690   	  	,Space(6-Len(Alltrim(Str(aListHS[26]))))+Transform(aListHS[26],"@E 999999")        ,oArial14N)
//=================================================================
//Total de Exames Efetuados
//=================================================================
nLin+=80
oPrint:Say(nLin,nCol+690   	  	,Space(6-Len(Alltrim(Str(aListHS[27]))))+Transform(aListHS[27],"@E 999999")        ,oArial14N)
//=================================================================
//N∞ de visitas efetuadas aos postos de Trabalho
//=================================================================
nLin+=80
oPrint:Say(nLin,nCol+690   	  	,Space(6-Len(Alltrim(Str(aListHS[28]))))+Transform(aListHS[28],"@E 999999")        ,oArial14N)
//=================================================================
//Desp.Medicina de Trabalho
//=================================================================
nLin+=140
oPrint:Say(nLin,nCol+500   	  	,Space(14-Len(Alltrim(Str(aListHS[29]))))+Transform(aListHS[29],"@E 999,999,999.99")        ,oArial14N)
//**********************************************************************************************************************************
//COMISSOES DE HIGIENE E SEGURANCA
//**********************************************************************************************************************************
//=================================================================
//Reunioes Anuais de Higiene e Seguranca(Comissoes de Higiene e seguranca)
//=================================================================
nLin+=310
oPrint:Say(nLin,nCol+690   	  	,Space(6-Len(Alltrim(Str(aListHS[30]))))+Transform(aListHS[30],"@E 999999")        ,oArial14N)
//=================================================================
//Visitas aos Locais de Trabalho(Comissoes de Higiene e seguranca)
//=================================================================
nLin+=90
oPrint:Say(nLin,nCol+690   	  	,Space(6-Len(Alltrim(Str(aListHS[31]))))+Transform(aListHS[31],"@E 999999")        ,oArial14N)
//**********************************************************************************************************************************
//PESSOAS RECLASSIFICADAS OU RECOLOCADAS EM RESULTADOS DE ACIDENTE DE TRABALHO  
//**********************************************************************************************************************************
//=================================================================
//N∞ de Pessoas(Acoes de Segurancae Sensibilizacao de acidente de trabalho)
//=================================================================
nLin+=290
oPrint:Say(nLin,nCol+690   	  	,Space(6-Len(Alltrim(Str(aListHS[32]))))+Transform(aListHS[32],"@E 999999")        ,oArial14N)
//**********************************************************************************************************************************
//ACOES DE FORMACAO E SENSIBILIZACAO EM MATERIA DE SEGURANCA DE TRABALHO
//**********************************************************************************************************************************
//=================================================================
//N∞de acoes desenvolvidas
//=================================================================
nLin+=310
oPrint:Say(nLin,nCol+690   	  	,Space(6-Len(Alltrim(Str(aListHS[33]))))+Transform(aListHS[33],"@E 999999")        ,oArial14N)
//=================================================================
//N∞ de pessoas abrangidas pela acao
//=================================================================
nLin+=080
oPrint:Say(nLin,nCol+690   	  	,Space(6-Len(Alltrim(Str(aListHS[34]))))+Transform(aListHS[34],"@E 999999")        ,oArial14N)

oPrint:EndPage() 		// Finaliza a pagina
//=================================================================================================================================================
//PAGINA 10========================================================================================================================================
//=================================================================================================================================================
oPrint:StartPage() 		// Inicia uma nova pagina		
oPrint:Saybitmap(010,010,cStartPath+"BS10"+".bmp",2500,3400)  
nLin:=240 
nCol:=460
//**********************************************************************************************************************************
//CUSTOS COM A PREVENCAO DE ACIDENTES E DOENCAS PROFISSIONAIS
//**********************************************************************************************************************************
//=================================================================
//Encargos da Estrutura da Medicina de Trabalho e seguranca
//=================================================================

oPrint:Say(nLin,nCol+1480   	  	,Space(14-Len(Alltrim(Str(aListHS[35]))))+Transform(aListHS[35] ,"@E 999,999,999.99"),oArial14N)
//=================================================================
//Custos com equipamento de protecao
//=================================================================
nLin+=70
oPrint:Say(nLin,nCol+1480   	  	,Space(14-Len(Alltrim(Str(aListHS[36]))))+Transform(aListHS[36] ,"@E 999,999,999.99"),oArial14N)
//=================================================================
//Custos com Formacao e Prevencao
//=================================================================
nLin+=70
oPrint:Say(nLin,nCol+1480   	  	,Space(14-Len(Alltrim(Str(aListHS[37]))))+Transform(aListHS[37] ,"@E 999,999,999.99"),oArial14N)
//=================================================================
//Outros Custos
//=================================================================
nLin+=70
oPrint:Say(nLin,nCol+1480   	  	,Space(14-Len(Alltrim(Str(aListHS[38]))))+Transform(aListHS[38] ,"@E 999,999,999.99"),oArial14N)

//=========================================================================================
//================================FORMACAO PROFISSIONAL==================================== 
//=========================================================================================
//**********************************************************************************************************************************
//NUMERO DE ACOES
//**********************************************************************************************************************************
//=================================================================
//Numero Total de Acoes
//=================================================================
nLin+=700
oPrint:Say(nLin,nCol+680   	      	,Space(6-Len(Alltrim(Str(aListFP[1][1]))))+Transform(aListFP[1][1],"@E 999999")        ,oArial14N)
oPrint:Say(nLin,nCol+940  	    	,Space(6-Len(Alltrim(Str(aListFP[1][2]))))+Transform(aListFP[1][2],"@E 999999")        ,oArial14N)
oPrint:Say(nLin,nCol+1200   	    ,Space(6-Len(Alltrim(Str(aListFP[1][3]))))+Transform(aListFP[1][3],"@E 999999")        ,oArial14N)
oPrint:Say(nLin,nCol+1440   	    ,Space(6-Len(Alltrim(Str(aListFP[1][4]))))+Transform(aListFP[1][4],"@E 999999")        ,oArial14N)
oPrint:Say(nLin,nCol+1720   	    ,Space(6-Len(Alltrim(Str(aListFP[1][5]))))+Transform(aListFP[1][5],"@E 999999")        ,oArial14N)
//=================================================================
//Numero de Acoes Internas
//=================================================================
nLin+=70
oPrint:Say(nLin,nCol+680       		,Space(6-Len(Alltrim(Str(aListFP[2][1]))))+Transform(aListFP[2][1],"@E 999999")        ,oArial14N)
oPrint:Say(nLin,nCol+940   	      	,Space(6-Len(Alltrim(Str(aListFP[2][2]))))+Transform(aListFP[2][2],"@E 999999")        ,oArial14N)
oPrint:Say(nLin,nCol+1200  	      	,Space(6-Len(Alltrim(Str(aListFP[2][3]))))+Transform(aListFP[2][3],"@E 999999")        ,oArial14N)
oPrint:Say(nLin,nCol+1440  	      	,Space(6-Len(Alltrim(Str(aListFP[2][4]))))+Transform(aListFP[2][4],"@E 999999")        ,oArial14N)
oPrint:Say(nLin,nCol+1720  	      	,Space(6-Len(Alltrim(Str(aListFP[2][5]))))+Transform(aListFP[2][5],"@E 999999")        ,oArial14N)
//=================================================================
//Numero de Acoes externas
//=================================================================
nLin+=70
oPrint:Say(nLin,nCol+680       		,Space(6-Len(Alltrim(Str(aListFP[3][1]))))+Transform(aListFP[3][1],"@E 999999")        ,oArial14N)
oPrint:Say(nLin,nCol+940   	      	,Space(6-Len(Alltrim(Str(aListFP[3][2]))))+Transform(aListFP[3][2],"@E 999999")        ,oArial14N)
oPrint:Say(nLin,nCol+1200 	      	,Space(6-Len(Alltrim(Str(aListFP[3][3]))))+Transform(aListFP[3][3],"@E 999999")        ,oArial14N)
oPrint:Say(nLin,nCol+1440 	      	,Space(6-Len(Alltrim(Str(aListFP[3][4]))))+Transform(aListFP[3][4],"@E 999999")        ,oArial14N)
oPrint:Say(nLin,nCol+1720  	      	,Space(6-Len(Alltrim(Str(aListFP[3][5]))))+Transform(aListFP[3][5],"@E 999999")        ,oArial14N)
//**********************************************************************************************************************************
//NUMERO DE PARTICIPANTES
//**********************************************************************************************************************************
//=================================================================
//Numero Total de Participantes
//=================================================================
nLin+=380
oPrint:Say(nLin,nCol+100   	      	,Space(6-Len(Alltrim(Str(aListFP[4][1]))))+Transform(aListFP[4][1],"@E 999999")        ,oArial14N)
oPrint:Say(nLin,nCol+300   	      	,Space(6-Len(Alltrim(Str(aListFP[4][2]))))+Transform(aListFP[4][2],"@E 999999")        ,oArial14N)
oPrint:Say(nLin,nCol+500   	      	,Space(6-Len(Alltrim(Str(aListFP[4][3]))))+Transform(aListFP[4][3],"@E 999999")        ,oArial14N)
oPrint:Say(nLin,nCol+700    	    ,Space(6-Len(Alltrim(Str(aListFP[4][4]))))+Transform(aListFP[4][4],"@E 999999")        ,oArial14N)
oPrint:Say(nLin,nCol+900    	    ,Space(6-Len(Alltrim(Str(aListFP[4][5]))))+Transform(aListFP[4][5],"@E 999999")        ,oArial14N)
oPrint:Say(nLin,nCol+1100   	    ,Space(6-Len(Alltrim(Str(aListFP[4][6]))))+Transform(aListFP[4][6],"@E 999999")        ,oArial14N)
oPrint:Say(nLin,nCol+1300   	    ,Space(6-Len(Alltrim(Str(aListFP[4][7]))))+Transform(aListFP[4][7],"@E 999999")        ,oArial14N)
oPrint:Say(nLin,nCol+1500   	    ,Space(6-Len(Alltrim(Str(aListFP[4][8]))))+Transform(aListFP[4][8],"@E 999999")        ,oArial14N)
oPrint:Say(nLin,nCol+1700   	    ,Space(6-Len(Alltrim(Str(aListFP[4][9]))))+Transform(aListFP[4][9],"@E 999999")        ,oArial14N)
//=================================================================
//Numero de Participantes em Acoes Internas
//=================================================================
nLin+=200
oPrint:Say(nLin,nCol+100   	      	,Space(6-Len(Alltrim(Str(aListFP[5][1]))))+Transform(aListFP[5][1],"@E 999999")        ,oArial14N)
oPrint:Say(nLin,nCol+300   	      	,Space(6-Len(Alltrim(Str(aListFP[5][2]))))+Transform(aListFP[5][2],"@E 999999")        ,oArial14N)
oPrint:Say(nLin,nCol+500   	      	,Space(6-Len(Alltrim(Str(aListFP[5][3]))))+Transform(aListFP[5][3],"@E 999999")        ,oArial14N)
oPrint:Say(nLin,nCol+700    	    ,Space(6-Len(Alltrim(Str(aListFP[5][4]))))+Transform(aListFP[5][4],"@E 999999")        ,oArial14N)
oPrint:Say(nLin,nCol+900    	    ,Space(6-Len(Alltrim(Str(aListFP[5][5]))))+Transform(aListFP[5][5],"@E 999999")        ,oArial14N)
oPrint:Say(nLin,nCol+1100   	    ,Space(6-Len(Alltrim(Str(aListFP[5][6]))))+Transform(aListFP[5][6],"@E 999999")        ,oArial14N)
oPrint:Say(nLin,nCol+1300   	    ,Space(6-Len(Alltrim(Str(aListFP[5][7]))))+Transform(aListFP[5][7],"@E 999999")        ,oArial14N)
oPrint:Say(nLin,nCol+1500   	    ,Space(6-Len(Alltrim(Str(aListFP[5][8]))))+Transform(aListFP[5][8],"@E 999999")        ,oArial14N)
oPrint:Say(nLin,nCol+1700   	    ,Space(6-Len(Alltrim(Str(aListFP[5][9]))))+Transform(aListFP[5][9],"@E 999999")        ,oArial14N)
//=================================================================                              
//Numero de Participantes em Acoes externas
//=================================================================
nLin+=200
oPrint:Say(nLin,nCol+100   	      	,Space(6-Len(Alltrim(Str(aListFP[6][1]))))+Transform(aListFP[6][1],"@E 999999")        ,oArial14N)
oPrint:Say(nLin,nCol+300   	      	,Space(6-Len(Alltrim(Str(aListFP[6][2]))))+Transform(aListFP[6][2],"@E 999999")        ,oArial14N)
oPrint:Say(nLin,nCol+500   	      	,Space(6-Len(Alltrim(Str(aListFP[6][3]))))+Transform(aListFP[6][3],"@E 999999")        ,oArial14N)
oPrint:Say(nLin,nCol+700    	    ,Space(6-Len(Alltrim(Str(aListFP[6][4]))))+Transform(aListFP[6][4],"@E 999999")        ,oArial14N)
oPrint:Say(nLin,nCol+900	   	    ,Space(6-Len(Alltrim(Str(aListFP[6][5]))))+Transform(aListFP[6][5],"@E 999999")        ,oArial14N)
oPrint:Say(nLin,nCol+1100   	    ,Space(6-Len(Alltrim(Str(aListFP[6][6]))))+Transform(aListFP[6][6],"@E 999999")        ,oArial14N)
oPrint:Say(nLin,nCol+1300   	    ,Space(6-Len(Alltrim(Str(aListFP[6][7]))))+Transform(aListFP[6][7],"@E 999999")        ,oArial14N)
oPrint:Say(nLin,nCol+1500   	    ,Space(6-Len(Alltrim(Str(aListFP[6][8]))))+Transform(aListFP[6][8],"@E 999999")        ,oArial14N)
oPrint:Say(nLin,nCol+1700   	    ,Space(6-Len(Alltrim(Str(aListFP[6][9]))))+Transform(aListFP[6][9],"@E 999999")        ,oArial14N)

//**********************************************************************************************************************************
//DURACAO DAS ACOES
//**********************************************************************************************************************************
//=================================================================
//Numero Total de Horas
//=================================================================
nLin+=400
oPrint:Say(nLin,nCol+100   	      	,Space(6-Len(Alltrim(Str(aListFP[7][1]))))+Transform(aListFP[7][1],"@E 999999")        ,oArial14N)
oPrint:Say(nLin,nCol+300   	      	,Space(6-Len(Alltrim(Str(aListFP[7][2]))))+Transform(aListFP[7][2],"@E 999999")        ,oArial14N)
oPrint:Say(nLin,nCol+500   	      	,Space(6-Len(Alltrim(Str(aListFP[7][3]))))+Transform(aListFP[7][3],"@E 999999")        ,oArial14N)
oPrint:Say(nLin,nCol+700    	    ,Space(6-Len(Alltrim(Str(aListFP[7][4]))))+Transform(aListFP[7][4],"@E 999999")        ,oArial14N)
oPrint:Say(nLin,nCol+900    	    ,Space(6-Len(Alltrim(Str(aListFP[7][5]))))+Transform(aListFP[7][5],"@E 999999")        ,oArial14N)
oPrint:Say(nLin,nCol+1100   	    ,Space(6-Len(Alltrim(Str(aListFP[7][6]))))+Transform(aListFP[7][6],"@E 999999")        ,oArial14N)
oPrint:Say(nLin,nCol+1300   	    ,Space(6-Len(Alltrim(Str(aListFP[7][7]))))+Transform(aListFP[7][7],"@E 999999")        ,oArial14N)
oPrint:Say(nLin,nCol+1500   	    ,Space(6-Len(Alltrim(Str(aListFP[7][8]))))+Transform(aListFP[7][8],"@E 999999")        ,oArial14N)
oPrint:Say(nLin,nCol+1700   	    ,Space(6-Len(Alltrim(Str(aListFP[7][9]))))+Transform(aListFP[7][9],"@E 999999")        ,oArial14N)

//=================================================================
//Numero de Horas em Acoes Internas
//=================================================================
nLin+=200
oPrint:Say(nLin,nCol+100   	      	,Space(6-Len(Alltrim(Str(aListFP[8][1]))))+Transform(aListFP[8][1],"@E 999999")        ,oArial14N)
oPrint:Say(nLin,nCol+300   	      	,Space(6-Len(Alltrim(Str(aListFP[8][2]))))+Transform(aListFP[8][2],"@E 999999")        ,oArial14N)
oPrint:Say(nLin,nCol+500   	      	,Space(6-Len(Alltrim(Str(aListFP[8][3]))))+Transform(aListFP[8][3],"@E 999999")        ,oArial14N)
oPrint:Say(nLin,nCol+700    	    ,Space(6-Len(Alltrim(Str(aListFP[8][4]))))+Transform(aListFP[8][4],"@E 999999")        ,oArial14N)
oPrint:Say(nLin,nCol+900    	    ,Space(6-Len(Alltrim(Str(aListFP[8][5]))))+Transform(aListFP[8][5],"@E 999999")        ,oArial14N)
oPrint:Say(nLin,nCol+1100   	    ,Space(6-Len(Alltrim(Str(aListFP[8][6]))))+Transform(aListFP[8][6],"@E 999999")        ,oArial14N)
oPrint:Say(nLin,nCol+1300   	    ,Space(6-Len(Alltrim(Str(aListFP[8][7]))))+Transform(aListFP[8][7],"@E 999999")        ,oArial14N)
oPrint:Say(nLin,nCol+1500   	    ,Space(6-Len(Alltrim(Str(aListFP[8][8]))))+Transform(aListFP[8][8],"@E 999999")        ,oArial14N)
oPrint:Say(nLin,nCol+1700   	    ,Space(6-Len(Alltrim(Str(aListFP[8][9]))))+Transform(aListFP[8][9],"@E 999999")        ,oArial14N)

//=================================================================
//Numero de Horas em Acoes externas
//=================================================================
nLin+=200
oPrint:Say(nLin,nCol+100   	      	,Space(6-Len(Alltrim(Str(aListFP[9][1]))))+Transform(aListFP[9][1],"@E 999999")        ,oArial14N)
oPrint:Say(nLin,nCol+300   	      	,Space(6-Len(Alltrim(Str(aListFP[9][2]))))+Transform(aListFP[9][2],"@E 999999")        ,oArial14N)
oPrint:Say(nLin,nCol+500   	      	,Space(6-Len(Alltrim(Str(aListFP[9][3]))))+Transform(aListFP[9][3],"@E 999999")        ,oArial14N)
oPrint:Say(nLin,nCol+700    	    ,Space(6-Len(Alltrim(Str(aListFP[9][4]))))+Transform(aListFP[9][4],"@E 999999")        ,oArial14N)
oPrint:Say(nLin,nCol+900    	    ,Space(6-Len(Alltrim(Str(aListFP[9][5]))))+Transform(aListFP[9][5],"@E 999999")        ,oArial14N)
oPrint:Say(nLin,nCol+1100   	    ,Space(6-Len(Alltrim(Str(aListFP[9][6]))))+Transform(aListFP[9][6],"@E 999999")        ,oArial14N)
oPrint:Say(nLin,nCol+1300   	    ,Space(6-Len(Alltrim(Str(aListFP[9][7]))))+Transform(aListFP[9][7],"@E 999999")        ,oArial14N)
oPrint:Say(nLin,nCol+1500   	    ,Space(6-Len(Alltrim(Str(aListFP[9][8]))))+Transform(aListFP[9][8],"@E 999999")        ,oArial14N)
oPrint:Say(nLin,nCol+1700   	    ,Space(6-Len(Alltrim(Str(aListFP[9][9]))))+Transform(aListFP[9][9],"@E 999999")        ,oArial14N)

//**********************************************************************************************************************************
//CUSTOS
//**********************************************************************************************************************************
//=================================================================
//Custos Totais em Acoes
//=================================================================
nLin+=220
oPrint:Say(nLin,nCol+1480   	      	,Space(14-Len(Alltrim(Str(aListFP[10][1]))))+Transform(aListFP[10][1],"@E 999,999,999.99")        ,oArial14N)
//=================================================================
//Custos em Acoes Internas
//=================================================================
nLin+=80
oPrint:Say(nLin,nCol+1480   	      	,Space(14-Len(Alltrim(Str(aListFP[11][1]))))+Transform(aListFP[11][1],"@E 999,999,999.99")        ,oArial14N)
//=================================================================
//Custos em Acoes externas
//=================================================================
nLin+=80
oPrint:Say(nLin,nCol+1480   	      	,Space(14-Len(Alltrim(Str(aListFP[12][1]))))+Transform(aListFP[12][1],"@E 999,999,999.99")        ,oArial14N)
                        

oPrint:EndPage() 		// Finaliza a pagina           
//=================================================================================================================================================
//PAGINA 11========================================================================================================================================
//=================================================================================================================================================
oPrint:StartPage() 		// Inicia uma nova pagina		
oPrint:Saybitmap(010,010,cStartPath+"BS11"+".bmp",2500,3400)  
nLin:=580 
nCol:=1800
//=========================================================================================
//===========================PROTECAO SOCIAL COMPLEMENTAR==================================
//=========================================================================================
//**********************************************************************************************************************************
//ENCARGOS DE PROTECAO SOCIAL SUPORTADOS PELA EMPRESA
//**********************************************************************************************************************************
//=================================================================
//Complementos de Subsidio por doenca e doenca profissional(Prestacoes)
//=================================================================
oPrint:Say(nLin,nCol   	      	,Space(6-Len(Alltrim(Str(nEdPsc1))))+Transform(nEdPsc1 ,"@E 999999")        ,oArial14N)
oPrint:Say(nLin,nCol+120   	  	,Space(14-Len(Alltrim(Str(nEdPsc2))))+Transform(nEdPsc2 ,"@E 999,999,999.99"),oArial14N)
//=================================================================
//Complementos de pensoes de velhice, de invalidez e de sobrevivencia(Prestacoes)
//=================================================================
nLin+=80
oPrint:Say(nLin,nCol   		  	,Space(6-Len(Alltrim(Str(nEdPsc3))))+Transform(nEdPsc3 ,"@E 999999")        ,oArial14N)
oPrint:Say(nLin,nCol+120   	  	,Space(14-Len(Alltrim(Str(nEdPsc4))))+Transform(nEdPsc4 ,"@E 999,999,999.99"),oArial14N)
//=================================================================
//Complementos de outras prestacoes de seguranca social(Prestacoes)
//=================================================================
nLin+=80
oPrint:Say(nLin,nCol   	  		,Space(6-Len(Alltrim(Str(nEdPsc5))))+Transform(nEdPsc5 ,"@E 999999")        ,oArial14N)
oPrint:Say(nLin,nCol+120	    ,Space(14-Len(Alltrim(Str(nEdPsc6))))+Transform(nEdPsc6 ,"@E 999,999,999.99"),oArial14N)
//**********************************************************************************************************************************
//ENCARGOS DE PROTECAO SOCIAL NAO ADMINISTRADOS PELA EMPRESA
//**********************************************************************************************************************************
//=================================================================
//Complementos de Subsidio por doenca e doenca profissional(Premios)
//=================================================================
nLin+=260
oPrint:Say(nLin,nCol   	  		,Space(6-Len(Alltrim(Str(nEdPsc7))))+Transform(nEdPsc7 ,"@E 999999")        ,oArial14N)
oPrint:Say(nLin,nCol+120  		,Space(14-Len(Alltrim(Str(nEdPsc8))))+Transform(nEdPsc8 ,"@E 999,999,999.99"),oArial14N)
//=================================================================
//Complementos de pensoes de velhice, de invalidez e de sobrevivencia(Premios)	
//=================================================================
nLin+=80
oPrint:Say(nLin,nCol   			,Space(6-Len(Alltrim(Str(nEdPsc9))))+Transform(nEdPsc9 ,"@E 999999")        ,oArial14N)
oPrint:Say(nLin,nCol+120   	  	,Space(14-Len(Alltrim(Str(nEdPsc10))))+Transform(nEdPsc10,"@E 999,999,999.99"),oArial14N)
//=================================================================
//Complementos de pensoes de velhice, de invalidez e de sobrevivencia(Premios)	
//=================================================================
nLin+=80
oPrint:Say(nLin,nCol   	  		,Space(6-Len(Alltrim(Str(nEdPsc11))))+Transform(nEdPsc11,"@E 999999")        ,oArial14N)
oPrint:Say(nLin,nCol+120  		,Space(14-Len(Alltrim(Str(nEdPsc12))))+Transform(nEdPsc12,"@E 999,999,999.99"),oArial14N)  
//**********************************************************************************************************************************
//PRESTACAO DE ACAO SOCIAL
//**********************************************************************************************************************************
//=================================================================
//Apoio a Infancia
//=================================================================
nLin+=280
oPrint:Say(nLin,nCol+120		,Space(14-Len(Alltrim(Str(nEdPsc13))))+Transform(nEdPsc13,"@E 999,999,999.99"),oArial14N)
//=================================================================
//Apoio a idosos
//=================================================================
nLin+=70
oPrint:Say(nLin,nCol+120		,Space(14-Len(Alltrim(Str(nEdPsc13))))+Transform(nEdPsc14,"@E 999,999,999.99"),oArial14N)
//=================================================================
//Apoio a tempo livres
//=================================================================
nLin+=70
oPrint:Say(nLin,nCol+120		,Space(14-Len(Alltrim(Str(nEdPsc15))))+Transform(nEdPsc15,"@E 999,999,999.99"),oArial14N)
//=================================================================
//Outros apoios
//=================================================================
nLin+=70
oPrint:Say(nLin,nCol+120		,Space(14-Len(Alltrim(Str(nEdPsc16))))+Transform(nEdPsc16,"@E 999,999,999.99"),oArial14N)
//OUTRAS MODALIDADES DE APOIO SOCIAL
//=================================================================
//Grupos desportivos/casa de pessoal
//=================================================================
nLin+=350
oPrint:Say(nLin,nCol+120		,Space(14-Len(Alltrim(Str(nEdPsc17))))+Transform(nEdPsc17,"@E 999,999,999.99"),oArial14N)
//=================================================================
//Alimentacao
//=================================================================
nLin+=70
oPrint:Say(nLin,nCol+120		,Space(14-Len(Alltrim(Str(nEdPsc18))))+Transform(nEdPsc18,"@E 999,999,999.99"),oArial14N)
//=================================================================
//Apoio a estudos
//=================================================================
nLin+=75
oPrint:Say(nLin,nCol+120		,Space(14-Len(Alltrim(Str(nEdPsc19))))+Transform(nEdPsc19,"@E 999,999,999.99"),oArial14N)
//=================================================================
//Saude
//=================================================================
nLin+=70
oPrint:Say(nLin,nCol+120		,Space(14-Len(Alltrim(Str(nEdPsc20))))+Transform(nEdPsc20,"@E 999,999,999.99"),oArial14N)
//=================================================================
//Habitacao
//=================================================================
nLin+=70
oPrint:Say(nLin,nCol+120		,Space(14-Len(Alltrim(Str(nEdPsc21))))+Transform(nEdPsc21,"@E 999,999,999.99"),oArial14N)
//=================================================================
//Transportes
//=================================================================
nLin+=70
oPrint:Say(nLin,nCol+120		,Space(14-Len(Alltrim(Str(nEdPsc22))))+Transform(nEdPsc22,"@E 999,999,999.99"),oArial14N)
//=================================================================
//Seguros especiais
//=================================================================
nLin+=70
oPrint:Say(nLin,nCol+120		,Space(14-Len(Alltrim(Str(nEdPsc23))))+Transform(nEdPsc23,"@E 999,999,999.99"),oArial14N)
//=================================================================
//Adiantamento e emprestimos
//=================================================================
nLin+=75
oPrint:Say(nLin,nCol+120		,Space(14-Len(Alltrim(Str(nEdPsc24))))+Transform(nEdPsc24,"@E 999,999,999.99"),oArial14N)
//=================================================================
//Outros apoios
//=================================================================
nLin+=70
oPrint:Say(nLin,nCol+120		,Space(14-Len(Alltrim(Str(nEdPsc25))))+Transform(nEdPsc25,"@E 999,999,999.99"),oArial14N)
oPrint:EndPage() 		// Finaliza a pagina           
Return