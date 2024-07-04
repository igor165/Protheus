#INCLUDE "PROTHEUS.CH"
#INCLUDE "RWMAKE.CH"
#INCLUDE "GPER858.CH"
#INCLUDE "TOPCONN.CH"
/*
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao   ³ GPER858 ³ Autor ³Marcos Kato                      ³ Data ³ 14/01/09  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao³ Relatório ARI										                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Programador ³ Data     ³   BOPS    ³  Motivo da Alteracao                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Tiago Malta ³16/05/2011³009206/2011³Ajustes no layout do relatorio.             ³±± 
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±³ Uso     ³ Microsiga						                                       ³±±
±±ÀÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
*/
Function GPER858()
Local cString		:= "SRA"
Local nomeProg 		:= "GPER858"
Local cPerg     	:= "GPER858"
Local cDesc1		:=STR0001//"Imposto sobre a Renda - ARI"
Local cDesc2 		:=STR0002//"Ser  impresso de acordo com os parametros solicitados pelo"
Local cDesc3 		:=STR0003//"usuario."
Local aArea			:= GetArea()
Local cTamanho		:="P"
Local nCont			:= 0
Private oPrint
Private cTitulo 	:= STR0001//"Comprovante de Retencao ISLR"
Private aReturn 	:= {STR0004, 1,STR0005, 2, 1, 1, "",1 }//Zebrado#Administracao
Private oArial10N	:= TFont():New("Arial",10,10,,.T.,,,,.F.,.F.)
Private oArial12N	:= TFont():New("Arial",12,12,,.T.,,,,.F.,.F.)
Private cStartPath	:= GetSrvProfString("Startpath","")
Private nLin		:= 0 ,nCol		  	:= 0 ,nPag			:= 0
Private cProces		:= "",cAnoBas		:= "",cMesBas		:= "",cPeriod		:= "",cRotSra		:= ""
Private cFilSra		:= "",cCCusto		:= "",cDepart		:= ""
Private cMatric		:= "",cSitua 		:= "",cCateg        := "",cNome  		:= ""

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Verifica as perguntas selecionadas                           ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Pergunte(cPerg,.F.)
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Envia controle para a funcao SETPRINT                        ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
wnrel := "GPER858"

wnrel:=SetPrint(cString,wnrel,cPerg,@cTitulo,cDesc1,cDesc2,cDesc3,.F.,,,cTamanho,,.F.)

If nLastKey = 27
	Return                 
Endif

SetDefault(aReturn,cString)

If nLastKey = 27
	Return
Endif
//=======================================================================
//MV_PAR01 - PROCESSO
//MV_PAR02 - ANO DO COMPROVANTE DE RENDA
//MV_PAR03 - MES
//MV_PAR04 - FILIAL
//MV_PAR05 - CENTRO DE CUSTO
//MV_PAR06 - DEPARTAMENTO
//MV_PAR07 - MATRICULA
//MV_PAR08 - SITUACAO
//MV_PAR09 - NOME DO FUNCIONARIO
//MV_PAR10 - CATEGORIA
//=======================================================================
cProces:=MV_PAR01
cAnoBas:=MV_PAR02
cMesBas:=MV_PAR03
cFilSra:=IIF(EMPTY(MV_PAR04),"",RANGESX1("RA_FILIAL",MV_PAR04))
cCCusto:=IIF(EMPTY(MV_PAR05),"",RANGESX1("RA_CC"    ,MV_PAR05))
cDepart:=IIF(EMPTY(MV_PAR06),"",RANGESX1("RA_DEPTO" ,MV_PAR06))
cMatric:=IIF(EMPTY(MV_PAR07),"",RANGESX1("RA_MAT"   ,MV_PAR07))
cSitua :="'"
For nCont:=1 To Len(MV_PAR08)
	cSitua+=Substr(MV_PAR08,nCont,1)+"','"
Next                                  
cSitua:=Substr(cSitua,1,Len(cSitua)-2)    
If Empty(cSitua)
	cSitua:="' '"
Endif
cNome  :=IIF(EMPTY(MV_PAR09),"",RANGESX1("RA_NOME"  ,MV_PAR09))
cCateg:="'"
For nCont:=1 To Len(MV_PAR10)
	cCateg+=Substr(MV_PAR10,nCont,1)+"','"
Next                                  
cCateg:=Substr(cCateg,1,Len(cCateg)-2)
If Empty(cCateg)
	cCateg:="' '"
Endif

oPrint:= TMSPrinter():New( cTitulo)
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Verifica se ha impressora ativa conectada ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If ! oPrint:IsPrinterActive()
	oPrint:Setup()							//-- Escolhe a impressora
	If ! oPrint:IsPrinterActive()
	Help(" ",1,"NOPRINTGRA")			//-- Nao foi encontrada configuracao de impressora. ##Certifique-se de que as configurações da impressora estão corretas ou se há alguma impressora conectada.
		Return(Nil)
	Endif
Endif
//±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±//
//Modo de Impressao                                                           //
//oPrint:SetLandscape() - Impressao Paisagem                                  //
//oPrint:SetPortrait()  - Impressao Retrato                                   //
//±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±//
oPrint:SetPortrait()

MsgRun(STR0008,STR0007, {||CursorWait(),RELARI(),CursorArrow()})//"Processando Comprovante de Retencao"#"Aguarde..."

SET DEVICE TO SCREEN
MS_FLUSH()

RestArea( aArea)
Return

/*
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao   ³ RELARI ³  Autor ³Marcos Kato              ³ Data ³ 14/01/09 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao³ Contem todo o detalhe do Comprovante de Retencao ISLR ARI	   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso     ³ Microsiga						                               ³±±
±±ÀÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
*/
Static Function RELARI()
Local cQryArc    	:= "",cMat			:= "",cNomFunc		:= "",cRgFunc 		:= "",cCPFFunc 		:= "",cNacFunc 		:= ""
Local nMesCol       := 0 ,nVlrDed		:= 0 ,nVlrRem		:= 0 ,nVlrImp       := 0 ,nVlrIRA       := 0  
Local nTVlrIR       := 0 ,nVlrUT		:= 0 ,nVlrR13		:= 0 ,nVlrP13		:= 0 
Local nVlrD13		:= 0 ,nDedC1        := 0 ,nDedC2        := 0 ,nDedC3       := 0 ,nDedC4        := 0 ,nTDedC        := 0 
Local nImpAno       := 0 ,nAbPNat       := 0 ,nOnFam        := 0 ,nQtdDep      := 0 ,nImpRAnt      := 0 ,nPorcRet      := 0                   
Local nPorVar		:= 0 ,aTabARI       := {},nDesgUni      := 0 ,cEmpNomA 	:= "",cVerba		:= "" ,nValorI       := 0
Local aTabUT        := {},aEmpCor       :={},nPos           := 0,nPosTab       := 0,cQryAri       := "", aRet          := {}
//==============================================================================================================================================
//====================================Processando Comprovante de Retencao ISLR==================================================================
//==============================================================================================================================================
                 
cQryAri:="SELECT RA_FILIAL,RA_MAT,RA_PRINOME,RA_SECNOME,RA_NOME,RA_CIC,RA_RG,RA_NACIONA,RA_SALARIO ,RGS.* "
cQryAri+=" FROM "+RetSqlName("SRA")+" SRA "
cQryAri+=" INNER JOIN "+RetSqlName("RGS")+" RGS ON RGS_FILIAL = RA_FILIAL AND RGS_MAT = RA_MAT "
cQryAri+=" WHERE SRA.D_E_L_E_T_='' AND RGS.D_E_L_E_T_='' "
If !Empty(cFilSra)                     
	cQryAri+="AND "+cFilSra
Endif
If !Empty(cCCusto)
	cQryAri+="AND "+cCCusto
Endif
If !Empty(cDepart)
	cQryAri+="AND "+cDepart
Endif
If !Empty(cMatric)
	cQryAri+="AND "+cMatric
Endif
If !Empty(cNome)
	cQryAri+="AND "+cNome
Endif               
cQryAri+="AND RA_CATFUNC IN ("+cCateg+")
cQryAri+="AND RA_SITFOLH IN ("+cSitua+") "	
cQryAri+="AND RA_PROCES ='"+cProces+"' "
cQryAri+="AND RGS_MES ='"+cMesBas+"' "
cQryAri+="AND RGS_ANO ='"+cAnoBas+"' "

cQryAri+="ORDER BY RA_FILIAL,RA_MAT "
cQryAri:= ChangeQuery(cQryAri)

If Select("TRBARI")>0
	DbSelectArea("TRBARI")
	TRBARI->(DbCloseArea())
Endif

dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQryAri),"TRBARI",.F.,.T.)
If TRBARI->(!Eof())       
	
	fRetTab(@aTabUT,"S002",,,dDataBase)
	IF Len(aTabUT) > 0 
		nVlrUT:=aTabUT[5]
	ENDIF 
	
	fRetTab(@aTabARI ,"S023",,,dDataBase)
	IF Len(aTabARI) > 0 
		nDesgUni:=aTabARI[7]
	ENDIF
	
	While TRBARI->(!Eof()) 

		aEmpCor     :=FWLoadSM0()
		nPos        := aScan( aEmpcor , { |x| x[1] == cEmpant .and. x[2] == cFilant  } )
		cNomFunc	:=IIF(EMPTY(TRBARI->RA_PRINOME),ALLTRIM(TRBARI->RA_NOME),ALLTRIM(TRBARI->RA_PRINOME)+" "+ALLTRIM(TRBARI->RA_SECNOME))//Nome do Funcionario
		cRgFunc 	:=ALLTRIM(TRBARI->RA_RG)                                     //Rg do Funcionario		
		cCPFFunc 	:=ALLTRIM(TRBARI->RA_CIC)                                    //Cgc do Funcionario		
		cNacFunc    :=ALLTRIM(TRBARI->RA_NACIONA)                                //Nacionalidade do Funcionario		
        cEmpNomA 	:=IIF(EMPTY(aEmpCor[nPos][SM0_NOME]),aEmpCor[nPos][SM0_NOMRED],aEmpCor[nPos][SM0_NOME])   //Nome da Empresa
		MsgRun(TRBARI->RA_MAT+"-"+cNomFunc,STR0007, {||})//"Processando Comprovante de Retencao"#"Aguarde..."

		nDedC1        := RGS->RGS_INSTEN
		nDedC2        := RGS->RGS_SEGSAL
		nDedC3        := RGS->RGS_SERVME
		nDedC4        := RGS->RGS_INTERA
		nTDedC        := nDedC1+nDedC2+nDedC3+nDedC4
		nQtdDep       := RGS->RGS_QTDDEP+RGS->RGS_DEPASC+RGS->RGS_DEPDES
		nOnFam        := RGS->RGS_CARGAF
		nAbPNat       := RGS->RGS_REBAJP
		nImpRAnt      := RGS->RGS_IMPEST
      
	/*	dbSelectArea("SRV")
		SRV->(DbSetOrder(2))
		SRV->(DbGoTop())
		If Dbseek(xFilial("SRV")+"0015")//015-Indentificador de calculo valor de Base IR
			cVerba:=SRV->RV_COD//Codigo da Verba Vlr.Base IR	
		Endif               */
		cMat:=TRBARI->RA_MAT
		nVlrDed:=0     
		nVlrRem:=0
		nVlrImp:=0          
		nVlrIRA:=0
		  /*		Do While TRBARI->(!Eof()) .And. cMat==TRBARI->RA_MAT
			If TRBARI->RV_DIRF=="8"//Deducoes
				nVlrDed+=TRBARI->RD_VALOR
			ElseIf TRBARI->RV_DIRF=="7"//Imposto Retidos
				nVlrImp+=TRBARI->RD_VALOR
			Else	
				nVlrRem+=TRBARI->RD_VALOR
			Endif
			cMat:=TRBARI->RA_MAT			
			TRBARI->(DbSkip())                
		End		                   */
		
		nVlrIRA+=TRBARI->RA_SALARIO * ( 12 - Val(cMesBas) ) + 1  //Valor da Base IR
		nTVlrIR  := nVlrIRA
		nTDedC   :=(nDedC1+nDedC2+nDedC3+nDedC4)
	              
		nLin:=370                 
		nCol:=100     
		oPrint:StartPage()
		oPrint:Saybitmap(40,40,cStartPath+"ARI"+".JPG",2500,3200)   
		nLin+=170 
		If cNacFunc=="60"
			oPrint:Say(nLin  ,nCol+1150 ,"X"					               								 ,oArial10N)//"Nacionalidade venezuelana"		
			oPrint:Say(nLin  ,nCol+1300 ,cRgFunc					               							 ,oArial10N)//"RG"
		Else
			oPrint:Say(nLin+40,nCol+1150 ,"X"					               								 ,oArial10N)//"Outra nacionalidade"		
			oPrint:Say(nLin+40,nCol+1300 ,cRgFunc					               							 ,oArial10N)//"RG"			
		Endif
		nLin+=020                                                                                		
		oPrint:Say(nLin  ,nCol      ,cNomFunc																 ,oArial10N)//"Sobrenome e Nome"
		oPrint:Say(nLin  ,nCol+1620 ,Substr(cCPFFunc,1,1)		               								 ,oArial10N)//"RG"
		oPrint:Say(nLin  ,nCol+1680 ,Substr(cCPFFunc,2,1)		               								 ,oArial10N)//"RG"
		oPrint:Say(nLin  ,nCol+1740 ,Substr(cCPFFunc,3,1)		               								 ,oArial10N)//"RG"
		oPrint:Say(nLin  ,nCol+1800 ,Substr(cCPFFunc,4,1)		               								 ,oArial10N)//"RG"
		oPrint:Say(nLin  ,nCol+1860 ,Substr(cCPFFunc,5,1)		               								 ,oArial10N)//"RG"
		oPrint:Say(nLin  ,nCol+1920 ,Substr(cCPFFunc,6,1)		               								 ,oArial10N)//"RG"
		oPrint:Say(nLin  ,nCol+1980 ,Substr(cCPFFunc,7,1)		               								 ,oArial10N)//"RG"
		oPrint:Say(nLin  ,nCol+2050 ,Substr(cCPFFunc,8,1)		               								 ,oArial10N)//"RG"
		oPrint:Say(nLin  ,nCol+2120 ,Substr(cCPFFunc,9,1)		               								 ,oArial10N)//"RG"																
		oPrint:Say(nLin  ,nCol+2180 ,Substr(cCPFFunc,10,1)		               								 ,oArial10N)//"RG"																
		nLin+=110                                                                                
		oPrint:Say(nLin  ,nCol      ,cEmpNomA	 															 ,oArial10N)//"Nome Pessoa Juridica"
		nLin+=20
		oPrint:Say(nLin  ,nCol+2080 ,cAnoBas																 ,oArial10N)//"Periodo Final - Ano"
		nMesCol:=0
		nMesLin:=nLin-5
        If cMesBas == "03" .and. RGS->RGS_CODIGO <> "1R"//Primeira Relacional
			oPrint:Say(nMesLin+60  ,nCol+1510 ,"X"															 ,oArial10N)
			nMesCol+=110
        Endif
        If cMesBas == "06" .and. RGS->RGS_CODIGO <> "1R"//Primeira variacao
			oPrint:Say(nMesLin+60  ,nCol+nMesCol+1535 ,"X"													 ,oArial10N)
			nMesCol+=120			
        Endif
        If cMesBas == "09" .and. RGS->RGS_CODIGO <> "1R"//Segunda variacao
			oPrint:Say(nMesLin+60  	,nCol+nMesCol+1555 ,"X"													 ,oArial10N)
			nMesCol+=140
        Endif
        If cMesBas == "12" .and. RGS->RGS_CODIGO <> "1R"//Terceira variacao
			oPrint:Say(nMesLin+60	,nCol+nMesCol+1555 ,"X"													 ,oArial10N)
        Endif  
        nLin+=260       
        nCol:=50 
   		oPrint:Say(nLin  ,nCol+300  ,AliDir(nVlrIRA										,"@E 999,999,999,999.99"),oArial10N)//A)Valor Base IR A
   		nLin+=260
   		oPrint:Say(nLin  ,nCol+250  ,AliDir(nTVlrIR       								,"@E 999,999,999,999.99"),oArial10N)//B)Valor Total IR
   		oPrint:Say(nLin  ,nCol+1010 ,AliDir(nVlrUT 		  								,"@E 999,999,999,999.99"),oArial10N)//B)Valor Unidade Tributaria	
   		oPrint:Say(nLin  ,nCol+1780 ,AliDir(nTVlrIR/nVlrUt								,"@E 999,999,999,999.99"),oArial10N)//B)valor Total IR X Valor Unidade Tributaria	
   		nLin+=135
   		oPrint:Say(nLin  ,nCol+1780 ,AliDir(nDedc1										,"@E 999,999,999,999.99"),oArial10N)//C)Valor Deducao 1 - Institutos Docentes... 
   		nLin+=35
   		oPrint:Say(nLin  ,nCol+1780 ,AliDir(nDedC2										,"@E 999,999,999,999.99"),oArial10N)//C)Valor Deducao 2 - Primas de Seguros de Hospitalizacao...
   		nLin+=40
   		oPrint:Say(nLin  ,nCol+1780 ,AliDir(nDedC3										,"@E 999,999,999,999.99"),oArial10N)//C)Valor Deducao 3 - servicos Medicos... 
   		nLin+=45
   		oPrint:Say(nLin  ,nCol+1780 ,AliDir(nDedC4										,"@E 999,999,999,999.99"),oArial10N)//C)Valor Deducao 4 - Intereses para la ... 
   		nLin+=050
   		oPrint:Say(nLin  ,nCol+1780 ,AliDir(nTDedC	   									,"@E 999,999,999,999.99"),oArial10N)//C)Total Deducao
   		nLin+=110   		                                                                                
   		oPrint:Say(nLin  ,nCol+250  ,AliDir(nTDedC	     								,"@E 999,999,999,999.99"),oArial10N)//D)Total Deducao
   		oPrint:Say(nLin  ,nCol+980 ,AliDir(nVlrUT 		 								,"@E 999,999,999,999.99"),oArial10N)//D)Valor Unidade Tributaria	   		
   		oPrint:Say(nLin  ,nCol+1780 ,AliDir(nTDedC/nVlrUt								,"@E 999,999,999,999.99"),oArial10N)//D)Total Deducao X Valor Unidade Tributaria
		nLin+=090   		                                                                                   		   		
   		oPrint:Say(nLin  ,nCol+1780 ,AliDir(nDesgUni						,"@E 999,999,999,999.99"),oArial10N)//E)Valor Deducao+Total Ded. com o calculo U.T.
		nLin+=080   		                                                                                   		
		oPrint:Say(nLin  ,nCol+060  ,AliDir(nTVlrIR/nVlrUt								,"@E 999,999,999,999.99"),oArial10N)//F)Total IR com o calculo da U.T.
   		oPrint:Say(nLin  ,nCol+860  ,AliDir(nVlrDed+(nTDedC/nVlrUt)						,"@E 999,999,999,999.99"),oArial10N)//F)Valor Deducao+Total Ded. com o calculo U.T.
   		oPrint:Say(nLin  ,nCol+1780 ,AliDir((nTVlrIR/nVlrUt)-(nVlrDed+(nTDedC/nVlrUt))	,"@E 999,999,999,999.99"),oArial10N)//F)
		nLin+=170  
		
    	nPosTab:= fPosTab("S013", nTVlrIR*nVlrUt , "<=", 4)         
    	If nPosTab > 0 
    		nVlrR13:=fTabela("S013", nPosTab, 4 )//Remuneracao
			nVlrP13:=fTabela("S013", nPosTab, 5 )//Porcentagem
			nVlrD13:=fTabela("S013", nPosTab, 6 )//Deducao
    		nImpAno:= ( ( nTVlrIR/nVlrUt - nDesgUni) * ( nVlrP13 / 100 ) ) - nVlrD13
		Endif
		
  		oPrint:Say(nLin  ,nCol+1780 ,AliDir(nImpAno										,"@E 999,999,999,999.99"),oArial10N)//G)Imposto do ano
   		nLin+=70
		oPrint:Say(nLin  ,nCol+1270 ,AliDir(nAbPNat										,"@E 999,999,999,999.99"),oArial10N)//H)Abatimento pessoa natural
		nLin+=35            
		oPrint:Say(nLin  ,nCol+800  ,Transform(nQtdDep,"@E 999")                                                ,oArial10N)//H)Quantidade depedente
		oPrint:Say(nLin  ,nCol+1270 ,AliDir(nQtdDep*nOnFam								,"@E 999,999,999,999.99"),oArial10N)//H)Onus Familiar
		nLin+=65            
		oPrint:Say(nLin  ,nCol+1270 ,AliDir(nImpRAnt  									,"@E 999,999,999,999.99"),oArial10N)//H)Imposto retidos anos anteriores
		nLin+=50
		oPrint:Say(nLin  ,nCol+1780 ,AliDir((nAbPNat+(nQtdDep*nOnFam)+nImpRAnt)			,"@E 999,999,999,999.99"),oArial10N)//H)Total de ABATIMENTO
		nLin+=50
		oPrint:Say(nLin  ,nCol+1780 ,AliDir( nValorI := Abs(nImpAno-(nAbPNat+(nQtdDep*nOnFam)+nImpRAnt))			,"@E 999,999,999,999.99"),oArial10N)//I)Imposto do Ano - Total de ABATIMENTO
		nLin+=110
		oPrint:Say(nLin  ,nCol+1080 ,AliDir( Abs(nImpAno-(nAbPNat+(nQtdDep*nOnFam)+nImpRAnt))			,"@E 99,999,999,999.99"),oArial10N)//J)Imposto do Ano - Total de ABATIMENTO
		oPrint:Say(nLin  ,nCol+1440 ,AliDir( Abs( ( ( nImpAno-(nAbPNat+(nQtdDep*nOnFam)+nImpRAnt) ) / (nTVlrIR/nVlrUt) ) * 100 ),"@E 9,999,999.99" ) ,oArial10N)//J)Porcentagem de Retencao
		nLin+=40
		oPrint:Say(nLin  ,nCol+1080 ,AliDir(nTVlrIR/nVlrUt								,"@E 999,999,999,999.99"),oArial10N)//J)
		nLin+=155
		
		aRet := fRetAcmIR( TRBARI->RA_FILIAL , TRBARI->RA_MAT )
		IF Len(aRet) > 0
			nVlrRem := aRet[1][1]
			nVlrImp := aRet[1][2]
		Endif
		
		oPrint:Say(nLin  ,nCol+1780 ,AliDir(nVlrImp										,"@E 999,999,999,999.99")      ,oArial10N)//K)Imposto Retido
		nLin+=45
		oPrint:Say(nLin  ,nCol+1780 ,AliDir(nVlrRem										,"@E 999,999,999,999.99")	   ,oArial10N)//K)remuneracao		
		nLin+=95
		nPorVar:=(((nValorI*nVlrUT)-nVlrImp)/((nVlrIRA)-nVlrRem))
   		oPrint:Say(nLin  ,nCol+1180 ,AliDir( nValorI ,"@E 999,999,999,999.99"),oArial10N)//K)Valor Total IR
   		oPrint:Say(nLin  ,nCol+1400 ,AliDir(nVlrUT   								    ,"@E 999,999,999,999.99")      ,oArial10N)//K)Valor Unidade Tributaria	
		oPrint:Say(nLin  ,nCol+1560 ,AliDir(nVlrImp   							        ,"@E 999,999,999,999.99")	   ,oArial10N)//K)Valor 1
		oPrint:Say(nLin  ,nCol+1870 ,AliDir(nPorVar  									,"@E 9,999,999.99")     ,oArial10N)//K)valor por variacao
		nLin+=55                            
		oPrint:Say(nLin  ,nCol+1290 ,AliDir(nVlrIRA       	                        	,"@E 999,999,999,999.99")  ,oArial10N)//K)Valor A
		oPrint:Say(nLin  ,nCol+1550 ,AliDir(nVlrRem	 									,"@E 999,999,999,999.99")      ,oArial10N)//K)Valor 2
		oPrint:EndPage()
		
		TRBARI->(dbskip())
	Enddo
Else
	Aviso(STR0010,STR0009 ,{ "OK" } )//"Atencao"#"Nao ha informacoes para serem geradas.Verifique os parametros"	
Endif	        

If aReturn[5]==1
	oPrint:Preview()
Endif
Return        
//ALINHAMENTO
Static Function AliDir(nVlr,cPicture)
Local cRet:=""  

If Len(Alltrim(Str(Int(nVlr))))==12
	cRet:=PADL(" ",1," ")+alltrim(Transform(nVlr,cPicture))
ElseIf Len(Alltrim(Str(Int(nVlr))))==11                    
	cRet:=PADL(" ",3," ")+alltrim(Transform(nVlr,cPicture))
ElseIf Len(Alltrim(Str(Int(nVlr))))==10                    
	cRet:=PADL(" ",5," ")+alltrim(Transform(nVlr,cPicture))
ElseIf Len(Alltrim(Str(Int(nVlr))))==9                    
	cRet:=PADL(" ",8," ")+alltrim(Transform(nVlr,cPicture))
ElseIf Len(Alltrim(Str(Int(nVlr))))==8                     
	cRet:=PADL(" ",10," ")+alltrim(Transform(nVlr,cPicture))
ElseIf Len(Alltrim(Str(Int(nVlr))))==7                       
	cRet:=PADL(" ",12," ")+alltrim(Transform(nVlr,cPicture))
ElseIf Len(Alltrim(Str(Int(nVlr))))==6                    
	cRet:=PADL(" ",15," ")+alltrim(Transform(nVlr,cPicture))
ElseIf Len(Alltrim(Str(Int(nVlr))))==5               
	cRet:=PADL(" ",17," ")+alltrim(Transform(nVlr,cPicture))
ElseIf Len(Alltrim(Str(Int(nVlr))))==4         
	cRet:=PADL(" ",19," ")+alltrim(Transform(nVlr,cPicture))
ElseIf Len(Alltrim(Str(Int(nVlr))))==3         
	cRet:=PADL(" ",22," ")+alltrim(Transform(nVlr,cPicture))
ElseIf Len(Alltrim(Str(Int(nVlr))))==2         
	cRet:=PADL(" ",24," ")+alltrim(Transform(nVlr,cPicture))
ElseIf Len(Alltrim(Str(Int(nVlr))))==1         
	cRet:=PADL(" ",26," ")+alltrim(Transform(nVlr,cPicture))
Endif	
If At("*",cRet)>0 
	cRet:="Null"
Endif
Return cRet


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³fRetAcmIR ºAutor  ³Tiago Malta         º Data ³  05/16/11   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³                                                            º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Static Function fRetAcmIR( cFil , cMat )    

Local cQryAr2  := ""
Local aResult  := {}
    
	cQryAr2+="SELECT CASE WHEN SUM(BASE_IR) IS NULL THEN 0 ELSE SUM(BASE_IR) END  BASE_IR , "
	cQryAr2+="CASE WHEN SUM(VALOR_IR) IS NULL THEN 0 ELSE SUM(VALOR_IR) END VALOR_IR FROM "
	cQryAr2+="( "
	cQryAr2+="SELECT Case when RV_CODFOL = '0015' then Sum(RD_VALOR) else 0 end BASE_IR , "
	cQryAr2+="Case when RV_CODFOL = '0066' then Sum(RD_VALOR) else 0 end VALOR_IR "
	cQryAr2+="FROM "+RetSqlName("SRD")+" SRD " 
	cQryAr2+="INNER JOIN "+RetSqlName("SRV")+" SRV ON "
	cQryAr2+="RV_COD=RD_PD "
	cQryAr2+="WHERE SRD.D_E_L_E_T_='' AND SRV.D_E_L_E_T_='' "
	cQryAr2+="AND RD_FILIAL = '"+cFil+"' "	
	cQryAr2+="AND RD_MAT = '"+cMat+"' "
	cQryAr2+="AND RV_CODFOL = '0015' OR RV_CODFOL = '0066' "
	cQryAr2+="AND LEFT(RD_DATARQ,4) = '"+cAnoBas+"' "
	cQryAr2+="GROUP BY RD_VALOR , RV_CODFOL "
	cQryAr2+="	) AB "
	cQryAr2:= ChangeQuery(cQryAr2)
	
	If Select("TRBAR2")>0
		DbSelectArea("TRBAR2")
		TRBAR2->(DbCloseArea())
	Endif
	
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQryAr2),"TRBAR2",.F.,.T.)             
	
	IF TRBAR2->( !EOF() )
		aAdd( aResult , {TRBAR2->BASE_IR , TRBAR2->VALOR_IR } )
	ENDIF
		                                  
Return(aResult)