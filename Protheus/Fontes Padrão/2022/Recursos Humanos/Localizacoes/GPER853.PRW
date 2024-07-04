#INCLUDE "PROTHEUS.CH"                       
#INCLUDE "RWMAKE.CH"  
#INCLUDE "GPER853.CH"
#INCLUDE "TOPCONN.CH"

/*
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao   ³ GPER853 ³ Autor ³Marcos Kato                      ³ Data ³ 12/12/08  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao³ Relatório INCES - SOLICITUD DE PAGO					               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Programador ³ Data     ³   BOPS    ³  Motivo da Alteracao                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Tiago Malta ³15/04/2011³005374/2011³Alterado o layout do relatorio.             ³±±
±±³Tiago Malta ³11/05/2011³009206/2011³Tratamento para a versao p11.               ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±³ Uso     ³ Microsiga						                                       ³±±
±±ÀÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
*/
Function GPER853()
Local cString		:= "SRA"
Local nomeProg 	:= "GPER853"
Local cPerg     	:= "GPER853"
Local cQryINCES	:=""
Local nVlrPos		:=0 , nVlrNeg    :=0 
Local cCodVer		:="", cDesVer    :="", cMesAnoIn:="", cMesAnoFi:="", cCateg := "", cSit := "", nCtd :=0
Local cDesc1		:=STR0001//"Solicitacao de Pagamento INCES"
Local cDesc2 		:=STR0002//"Ser  impresso de acordo com os parametros solicitados pelo"
Local cDesc3 		:=STR0003//"usuario."
Local aArea			:= GetArea()
Local cTamanho		:="P"
Private oPrint
Private cTitulo 	:= STR0004//"Relatorio de INCES" 
Private aReturn 	:= {STR0005, 1,STR0006, 2, 1, 1, "",1 }//Zebrado#Administracao
Private oArial10N	:= TFont():New("Arial",11,11,,.T.,,,,.F.,.F.)
Private oArial14N	:= TFont():New("Arial",14,14,,.T.,,,,.F.,.F.)
Private cStartPath	:= GetSrvProfString("Startpath","")
Private dDatFat		:= CTOD("//"),dDatVen:= CTOD("//")
Private cPrepar		:="",cRevisa:="",cNBanco:="",cNAgenc:=""
Private nVlrTot		:=0,nVlrTPs		:=0,nVlrTNg		:=0,nVlrJur:=0
Private aINCES	:= {}
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Verifica as perguntas selecionadas                           ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Pergunte(cPerg,.F.)
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Envia controle para a funcao SETPRINT                        ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
wnrel := "GPER853"             

wnrel:=SetPrint(cString,wnrel,cPerg,@cTitulo,cDesc1,cDesc2,cDesc3,.F.,,,cTamanho,,.F.)

If nLastKey = 27
	Return
Endif

SetDefault(aReturn,cString)

If nLastKey = 27
	Return           
Endif
//================================ 
// MV_PAR01 - FILIAL
// MV_PAR02 - CENTRO DE CUSTO
// MV_PAR03 - DEPTO
// MV_PAR04 - MATRICULA
// MV_PAR05 - NOME
// MV_PAR06 - SITUACAO
// MV_PAR07 - CATEGORIA  
// MV_PAR08 - MES/ANO  Inicio
// MV_PAR09 - MES/ANO  Fim
// MV_PAR10 - DATA DA FATURA
// MV_PAR11 - DATA DO VENCIMENTO
// MV_PAR12 - BANCO
// MV_PAR13 - AGENCIA
// MV_PAR14 - PREPARADO POR
// MV_PAR15 - REVISADO POR              
// MV_PAR16 - IMPRIME JUROS
// MV_PAR17 - JUROS
//================================  
       
nFilial 		:= 	MV_PAR01     

If !Empty(MV_PAR06) 	
	cSit			:=		"'"
	For nCtd:=1 To Len(Alltrim(MV_PAR06))
	   If Substr(MV_PAR06,nCtd,1) <> '*'
			cSit+=Substr(MV_PAR06,nCtd,1)+"','"
	   EndIf
	Next                                  
	MV_PAR06:=Substr(cSit,1,Len(cSit)-2)
Else	
	MV_PAR06:="' '"
EndIf

If !Empty(MV_PAR07) 
	cCateg:="'"
	For nCtd:=1 To Len(Alltrim(MV_PAR07))
	   If Substr(MV_PAR07,nCtd,1) <> '*'
			cCateg+=Substr(MV_PAR07,nCtd,1)+"','"
	   EndIf
	Next                                  
	MV_PAR07:=Substr(cCateg,1,Len(cCateg)-2) 
Else	
	MV_PAR07:="' '"
EndIf    

cMesAnoIn:=Substr(MV_PAR08,3,4)+Substr(MV_PAR08,1,2) 
cMesAnoFi:=Substr(MV_PAR09,3,4)+Substr(MV_PAR09,1,2)
dDatFat:=MV_PAR10
dDatVen:=MV_PAR11
cNBanco:=MV_PAR12
cNAgenc:=MV_PAR13
cPrepar:=MV_PAR14
cRevisa:=MV_PAR15                  
If MV_PAR16==2//1-Nao 2-Sim
	nVlrJur:=MV_PAR17//Valor Acrescentado no Total Geral
Endif
//==============================================================================================================================================
//=================================================Processando dados INCES======================================================================                                                                              
//==============================================================================================================================================
cQryINCES:="SELECT RV_DESCDET DESCR,RV_COD COD, "
cQryINCES+="CASE WHEN RV_TIPOCOD IN('1','3') THEN MAX(RD_VALOR) ELSE 0 END VLRNEG, "
cQryINCES+="CASE WHEN RV_TIPOCOD IN('2','4') THEN MAX(RD_VALOR) ELSE 0 END VLRPOS "
//cQryINCES+="FROM "+RETSQLNAME("SRD")+" SRD "
cQryINCES+="FROM "+RETSQLNAME("SRA")+" SRA,"+RETSQLNAME("SRD")+" SRD "
cQryINCES+="INNER JOIN "+RETSQLNAME("SRV")+" SRV ON " 
If Empty(xFilial("SRV"))
	cQryINCES += " 	RV_FILIAL = '"+xFilial("SRV")+"' "
Else
	cQryINCES += " 	RV_FILIAL = RA_FILIAL "
EndIf
cQryINCES+="   AND RV_COD=RD_PD "
cQryINCES+="	AND RV_CODFOL IN ('0843','0844','0854') "
cQryINCES+="	AND SRV.D_E_L_E_T_='' "
cQryINCES+="	WHERE SRD.D_E_L_E_T_='' "
//cQryINCES+="AND RD_DATARQ='"+cMesAno+"' "  
cQryINCES+="	AND SUBSTRING(RD_DATARQ,1,6) >='"+cMesAnoIn+"' "  
cQryINCES+="	AND SUBSTRING(RD_DATARQ,1,6) <='"+cMesAnoFi+"' " 
If !Empty(MV_PAR01)
	cQryINCES += " 	AND "+RANGESX1("RA_FILIAL"	,MV_PAR01)  
EndIf
If !Empty(MV_PAR02)
	cQryINCES += " 	AND "+RANGESX1("RA_CC"		,MV_PAR02)  
EndIf
If !Empty(MV_PAR03)
	cQryINCES += " 	AND "+RANGESX1("RA_DEPTO"	,MV_PAR03)  
EndIf
If !Empty(MV_PAR04)
	cQryINCES += " 	AND "+RANGESX1("RA_MAT"		,MV_PAR04)  
EndIf
If !Empty(MV_PAR05)
	cQryINCES += " 	AND "+RANGESX1("RA_NOME"	,MV_PAR05)  
EndIf 

cQryINCES += " 	AND RA_SITFOLH IN (" + MV_PAR06 + ")" 	

cQryINCES += " 	AND RA_CATFUNC IN (" + MV_PAR07 + ")" 
cQryINCES += " 	AND RD_FILIAL=RA_FILIAL "
cQryINCES += " 	AND RD_MAT=RA_MAT "  
cQryINCES+="GROUP BY RV_DESCDET,RV_COD,RV_TIPOCOD "
cQryINCES+="UNION  "
cQryINCES+="SELECT RV_DESCDET DESCR,RV_COD COD, "
cQryINCES+="CASE WHEN RV_TIPOCOD IN('1','3') THEN MAX(RC_VALOR) ELSE 0 END VLRPOS, "
cQryINCES+="CASE WHEN RV_TIPOCOD IN('2','4') THEN MAX(RC_VALOR) ELSE 0 END VLRNEG "
//cQryINCES+="FROM "+RETSQLNAME("SRC")+" SRC " 
cQryINCES += " FROM "+RETSQLNAME("SRA")+" SRA, " +RETSQLNAME("SRC")+" SRC "
cQryINCES+="INNER JOIN "+RETSQLNAME("SRV")+" SRV ON " 
If Empty(xFilial("SRV"))
	cQryINCES += " 	RV_FILIAL = '"+xFilial("SRV")+"' "
Else
	cQryINCES += " 	RV_FILIAL = RA_FILIAL "
EndIf
cQryINCES+=" 	AND RV_COD=RC_PD "
cQryINCES+="	AND RV_CODFOL IN ('0843','0844','0854') "
cQryINCES+="	AND SRV.D_E_L_E_T_='' "
cQryINCES+=" WHERE SRC.D_E_L_E_T_='' "
//cQryINCES+="AND RC_PERIODO='"+cMesAno+"' "  
cQryINCES+="	AND SUBSTRING(RC_DTREF,1,6) >='"+cMesAnoIn+"' "  
cQryINCES+="	AND SUBSTRING(RC_DTREF,1,6) <='"+cMesAnoFi+"' "  
If !Empty(MV_PAR01)
	cQryINCES += " 	AND "+RANGESX1("RA_FILIAL"	,MV_PAR01)  
EndIf
If !Empty(MV_PAR02)
	cQryINCES += " 	AND "+RANGESX1("RA_CC"		,MV_PAR02)  
EndIf
If !Empty(MV_PAR03)
	cQryINCES += " 	AND "+RANGESX1("RA_DEPTO"	,MV_PAR03)  
EndIf
If !Empty(MV_PAR04)
	cQryINCES += " 	AND "+RANGESX1("RA_MAT"		,MV_PAR04)  
EndIf
If !Empty(MV_PAR05)
	cQryINCES += " 	AND "+RANGESX1("RA_NOME"	,MV_PAR05)  
EndIf 
If !Empty(MV_PAR06)
 	cQryINCES += " 	AND RA_SITFOLH IN (" + MV_PAR06 + ")" 	
EndIf
If !Empty(MV_PAR07)
 	cQryINCES += " 	AND RA_CATFUNC IN (" + MV_PAR07 + ")"  
EndIf
cQryINCES += " 	AND RC_FILIAL=RA_FILIAL "
cQryINCES += " 	AND RC_MAT=RA_MAT "
cQryINCES+="GROUP BY RV_DESCDET,RV_COD,RV_TIPOCOD "
cQryINCES := ChangeQuery(cQryINCES)

If Select("TRBINCES")>0
	DbSelectArea("TRBINCES")
	TRBINCES->(DbCloseArea())
Endif
	
dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQryINCES),"TRBINCES",.F.,.T.)
	
Do While TRBINCES->(!Eof())    
	cCodVer:=TRBINCES->COD
	cDesVer:=TRBINCES->DESCR
	nVlrPos:=0
	nVlrNeg:=0
	Do While TRBINCES->(!Eof()) .And. cCodVer==TRBINCES->COD
   		nVlrPos:=TRBINCES->VLRPOS//Iif(MV_PAR16==1,TRBINCES->VLRPOS,(TRBINCES->VLRPOS/100)*nPorcen)
		nVlrNeg:=TRBINCES->VLRNEG//Iif(MV_PAR16==1,TRBINCES->VLRNEG,(TRBINCES->VLRNEG/100)*nPorcen)
		TRBINCES->(DbSkip()) 
    End                     
    nVlrTPs+=nVlrPos
    nVlrTNg+=nVlrNeg
    nVlrTot+=(nVlrPos-nVlrNeg)
    
    Aadd(aINCES,{cCodVer,cDesVer,nVlrNeg,nVlrPos})
End	      
If Len(aInces)>0
	aSort(aINCES,,,{|x,y|x[2]<y[2]})
	MsgRun(STR0007,STR0008, {||CursorWait(),RelINCES(aINCES),CursorArrow()})//Aguarde...#Processando INCES
Else
    Aviso(STR0029,STR0028 ,{ "OK" } )//"Atencao"#"Nao ha informacoes para serem geradas.Verifique os parametros"
Endif

RestArea( aArea)
Return 
	
/*
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao   ³ RelINCES ³ Autor ³Marcos Kato              ³ Data ³ 22/07/08 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao³ Contem todo o detalhe do relatorio Inces					   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso     ³ Microsiga						                               ³±±
±±ÀÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
*/

Static Function RelINCES(aINCES)             
Local nCont:=0     ,nQtd:=0
Private cNomEmp:="",cCGCEmp:=""
Private nLin	:= 0
Private nCol	:= 0

oPrint:= TMSPrinter():New( cTitulo)
//oPrint := TMsPrinter():New(::cTitle,,,,,,::lPreview,cFile,(::nRemoteType == NO_REMOTE .or. ::cPrinterName == CONST_SEMIMPRESS),(::nDevice <> IMP_DISCO))
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

CabINCES()       
nLin+=100     

For nCont:=1 To Len(aINCES)
	If nQtd>20 
		nQtd:=0   
		oPrint:Say(nLin,nCol+1000 ,STR0019,oArial14N)//<<<CONTINUA>>>
		oPrint:EndPage()	 
		oPrint:StartPage()	 
		CabINCES()       
		nLin+=100     
	Endif
	oPrint:Box(nLin-50 ,nCol,nLin+50,2200)
 //	oPrint:Line(nLin-50,600 ,nLin+50, 600)
	oPrint:Line(nLin-50,1700,nLin+50,1700)
   //	oPrint:Line(nLin-50,1820,nLin+50,1820)
	
//	oPrint:Say(nLin,nCol+300  ,aINCES[nCont][1],oArial14N)//Codigo da Verba
	oPrint:Say(nLin,nCol+100  ,aINCES[nCont][2],oArial10N)//Descricao da Verba 
	
	IF aINCES[nCont][3] > 0
		oPrint:Say(nLin,nCol+1650 ,Transform(aINCES[nCont][3],"@R 999,999,999.99"),oArial10N)//Valor da verba negativo
	ELSE
		oPrint:Say(nLin,nCol+1650 ,Transform(aINCES[nCont][4],"@R 999,999,999.99"),oArial10N)//Valor da verba positivo
	ENDIF
	
	nQtd++
	nLin+=100                        
Next           
If nVlrJur>0
	oPrint:Box(nLin-50 ,nCol,nLin+50,2200)
//	oPrint:Line(nLin-50,600 ,nLin+50, 600)
  //	oPrint:Line(nLin-50,1500,nLin+50,1500)
	oPrint:Line(nLin-50,1700,nLin+50,1700)
  //	oPrint:Say(nLin,nCol+300  ," - ",oArial14N)
	oPrint:Say(nLin,nCol+100  ,Upper(STR0030),oArial10N)
	oPrint:Say(nLin,nCol+1650 ,Transform(nVlrJur,"@R 999,999,999.99"),oArial10N)//Valor Juros
	nLin+=100                        
Endif
oPrint:Box(nLin-50 ,1700,nLin+50,2200)     
//oPrint:Line(nLin-50,1700,nLin+50,1700)
oPrint:Say(nLin,nCol+1300 ,STR0020                               ,oArial14N)//Totais
oPrint:Say(nLin,nCol+1600 ,Transform(nVlrTot+nVlrJur,"@R 999,999,999.99"),oArial14N)//Total Negativo
//oPrint:Say(nLin,nCol+1700 ,Transform(nVlrTPs,"@R 999,999,999.99"),oArial14N)//Total positivo 
nLin += 100

dDatFat:=MV_PAR10               
dDatVen:=MV_PAR11
cPrepar:=MV_PAR14
cRevisa:=MV_PAR15
nlin+=150           
//========================
//Rodape                 
//========================
oPrint:Box(nLin-50 ,nCol,nLin+200,2200)
oPrint:Line(nLin+50,nCol,nLin+50 ,2200)
oPrint:Line(nLin-50,700 ,nLin+200,700)
oPrint:Line(nLin-50,1200,nLin+200,1200)
oPrint:Line(nLin-50,1700,nLin+200,1700)
oPrint:Line(nLin-50,1970,nLin+200,1970)
oPrint:Say(nLin    ,nCol+040  ,STR0021  ,oArial10N)//Preparado
oPrint:Say(nLin    ,nCol+530  ,STR0022  ,oArial10N)//Revisado
oPrint:Say(nLin    ,nCol+1050 ,STR0023  ,oArial10N)//Favor emitir cheque
oPrint:Say(nLin    ,nCol+1530 ,STR0024  ,oArial10N)//Data da fatura
oPrint:Say(nLin    ,nCol+1800 ,STR0025  ,oArial10N)//Vencimento
nLin+=50
oPrint:Say(nLin+50 ,nCol+040  ,SUBSTR(cPrepar,1,30) ,oArial10N)//Preparado
oPrint:Say(nLin+50 ,nCol+535  ,SUBSTR(cRevisa,1,30) ,oArial10N)//Revisado
oPrint:Say(nLin+50 ,nCol+050  ,SUBSTR(cPrepar,30,30),oArial10N)//Preparado
oPrint:Say(nLin+50 ,nCol+535  ,SUBSTR(cRevisa,30,30),oArial10N)//Revisado
oPrint:Say(nLin+50 ,nCol+1540 ,DTOC(dDatFat)  		,oArial10N)//Data da fatura
oPrint:Say(nLin+50 ,nCol+1800 ,DTOC(dDatven)  		,oArial10N)//Vencimento
//oPrint:Say(nlin+100,nCol+050  ,DTOC(dDataBase)		,oArial10N)//data Base

oPrint:EndPage()                                    
If aReturn[5]==1
	MsgRun(STR0026,STR0007, {||CursorWait(),oPrint:Preview(),CursorArrow()})//Carregando#Aguarde... 
Else
	MsgRun(STR0027,STR0007, {||})//Imprimindo#Aguarde... 
Endif
  				
Return           
/*
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao   ³ CabINCES  ³ Autor ³Marcos Kato             ³ Data ³ 12/12/08 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao³ Cabecalho do relatorio INCES      					       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso     ³ Microsiga						                               ³±±
±±ÀÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
*/
Static Function CabINCES
Local cPagOrd:=STR0018//"I.N.C.E."
//oPrint:Saybitmap(010,010,cStartPath+"INCES"+".bmp",2500,3400)  
nLin:=200
nCol:=200     
oPrint:Say(nLin,nCol+800      ,STR0009,oArial14N)//Solicitacao de Pagamento
nLin+=200
oPrint:Line(nLin+50,nCol+600,nLin+50,2200)
oPrint:Say(nLin    ,nCol       ,STR0010,oArial10N)//Paga-se a ordem de:
oPrint:Say(nLin    ,nCol+800   ,cPagOrd,oArial10N)
nLin+=150                 
oPrint:Line(nLin+50,nCol,nLin+50,1600)
oPrint:Line(nLin+50,1800,nLin+50,2200)                                       
oPrint:Say(nLin,nCol+1500  ,STR0011,oArial10N)//"BS."
oPrint:Say(nLin,nCol+1680  ,Transform(nVlrTot+nVlrJur,"@E 999,999,999.99"),oArial14N)
nLin+=100                 
oPrint:Say(nLin,nCol      ,STR0012+cNBanco,oArial10N)//"Banco:   "
oPrint:Say(nLin,nCol+300  ,STR0013+cNAgenc,oArial10N)//"Agencia: "
nLin+=200                 
oPrint:Box(nLin-50,nCol ,nLin+50,2200)
//oPrint:Line(nLin-50,600 ,nLin+50, 600)
oPrint:Line(nLin-50,1700,nLin+50,1700)
//oPrint:Line(nLin-50,1820,nLin+50,1820)
//oPrint:Say(nLin,300       ,STR0014,oArial14N)//"CODIGO"
oPrint:Say(nLin,300       ,STR0015,oArial10N)//"DETALHE"
oPrint:Say(nLin,1900      ,STR0016,oArial10N)//"DEVER"
//oPrint:Say(nLin,1920      ,STR0017,oArial14N)//"HAVER"

Return                            