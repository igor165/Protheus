#INCLUDE "PROTHEUS.CH"                       
#INCLUDE "RWMAKE.CH"  
#INCLUDE "GPER855.CH"
#INCLUDE "TOPCONN.CH"

/*
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北
北谀哪哪哪哪履哪哪哪哪履哪哪哪履哪哪哪哪哪哪哪哪哪哪哪哪穆哪哪哪履哪哪哪哪哪哪哪哪某北
北矲uncao   � GPER855 � Autor 砅aulo Eduardo                    � Data � 19/12/08  潮�
北媚哪哪哪哪拍哪哪哪哪聊哪哪哪聊哪哪哪哪哪哪哪哪哪哪哪哪牧哪哪哪聊哪哪哪哪哪哪哪哪某北
北矰escricao� Pagamento RPVH - R間imen Prestacional de Vivienda y H醔itat	       潮�		                
北媚哪哪哪哪拍哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪某北
北砅rogramador � Data     �   BOPS    �  Motivo da Alteracao                       潮�
北媚哪哪哪哪哪呐哪哪哪哪哪拍哪哪哪哪哪拍哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪某北
北砊iago Malta �16/05/2011�009206/2011矨justes no layout do relatorio.             潮� 
北滥哪哪哪哪哪牧哪哪哪哪哪聊哪哪哪哪哪聊哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪某北
北� Uso     � TOTVS    					                                       	   潮�
北滥哪哪哪哪聊哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪某北
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北
*/
Function GPER855()
Local cString		:= "SRA"
Local nomeProg 	:= "GPER855"
Local cPerg     	:= "GPER855"
Local cQryRPVH		:= ""  
Local cTime			:= 0 ,	cPgm:=""
Local nVlrFun		:= 0 ,	nSalMes    :=0 ,	nVlrEmp	:=0	,	nTFunEmp	:=0
Local cCodVer		:= "",	cDesVer    :="",	cMesAno	:="" 	,	cMat		:="", cCateg := "", cSit := "", nCtd :=0
Local cDesc1		:= STR0001//"Solicitacao de Pagamento RPVH"
Local cDesc2 		:= STR0002//"Ser� impresso de acordo com os parametros solicitados pelo"
Local cDesc3 		:= STR0003//"usuario."
Local aArea			:= GetArea()
Local cTamanho		:= "P"                           
Local aOrd      	:= {STR0029,STR0030,STR0031}		//"Sobrenome+Nome"###"Depto+Sobrenome+Nome"###"cc+Depto+sobrenome+Nome"###
Private oPrint
Private cTitulo 	:= STR0004//"Relatorio de RPVH" 
Private aReturn 	:= {STR0005, 1,STR0006, 2, 1, 1, "",1 }//Zebrado#Administracao
Private oArial9N	:= TFont():New("Arial", 9, 9,,.T.,,,,.F.,.F.) 
Private oArial10N	:= TFont():New("Arial",10,10,,.T.,,,,.F.,.F.) 
Private oArial11N	:= TFont():New("Arial",11,11,,.T.,,,,.F.,.F.)
Private oArial12N	:= TFont():New("Arial",12,12,,.T.,,,,.F.,.F.)
Private oArial14N	:= TFont():New("Arial",14,14,,.T.,,,,.F.,.F.)
Private cStartPath:= GetSrvProfString("Startpath","")
Private dDatFat	:= CTOD("//"),dDatVen:= CTOD("//")
Private dDataDia	:= Date() 

Private cProcesso	:="" // Utilizada para a consulta do periodo no Pergunte
Private cPeriodo	:="" // Utilizada para a consulta do periodo no Pergunte  
Private lDissidio	:="" // Utilizada para a consulta do periodo no Pergunte  
Private cPrepar	:="",	cRevisa		:="",	cNBanco		:="",	cNAgenc			:=""
Private nVlrTot	:=0,	nVlrTFun		:=0 ,	nVlrTSalMes	:=0 ,	nVlrTSalBase	:=0 ,nVlrTEmp		:=0  
Private nVlrSTot	:=0,	nVlrSFun		:=0 ,	nVlrSSalMes	:=0 ,	nVlrSSalBase	:=0 ,nVlrSEmp		:=0
Private nCi			:=0,	nNro			:=0 , cDepto		:="", cCCusto	  		:="",cDeptoAtu		:="", cCCustoAtu	:="" 
Private cCNPJ 		:="", cNomEmp 		:="", cDesCC		:="", cDesDpto    	:="",cEndEmp		:=""
Private nRegSRA	:=0,	cFilSRA		:="", nPag			:=0	
Private aRPVH		:= {}
//谀哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪目
//� Verifica as perguntas selecionadas                           �
//滥哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪馁
Pergunte(cPerg,.F.)
//谀哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪目
//� Envia controle para a funcao SETPRINT                        �
//滥哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪馁
wnrel := "GPER855"             

wnrel:=SetPrint(cString,wnrel,cPerg,@cTitulo,cDesc1,cDesc2,cDesc3,.F.,aOrd,,cTamanho,,.F.)

If nLastKey = 27
	Return
Endif

SetDefault(aReturn,cString)

If nLastKey = 27
	Return
Endif
//================================
//  MV_PAR01 - FILIAL
//  MV_PAR02 - CENTRO DE CUSTO
//  MV_PAR03 - DEPTO
//  MV_PAR04 - MATRICULA
//  MV_PAR05 - NOME
//  MV_PAR06 - SITUACAO
//  MV_PAR07 - CATEGORIA
//  MV_PAR08 - MES/ANO
//  MV_PAR09 - PROCESSO  
//  MV_PAR10 - PERIODO
//  MV_PAR11 - NRO PAGTO  
//  MV_PAR12 - ROTINA DE CALCULO
//  
//================================    
/*
MV_PAR01:=RANGESX1("RA_FILIAL",MV_PAR01)
MV_PAR02:=RANGESX1("RA_CC"		,MV_PAR02)
MV_PAR03:=RANGESX1("RA_DEPTO"	,MV_PAR03)
MV_PAR04:=RANGESX1("RA_MAT"	,MV_PAR04)
MV_PAR05:=RANGESX1("RA_NOME"	,MV_PAR05)
*/  
If !Empty(MV_PAR08)
	cMesAno:=Substr(MV_PAR08,3,4)+Substr(MV_PAR08,1,2)   
EndIf

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

//==============================================================================================================================================
//=================================================Processando dados RPVH======================================================================                                                                              
//==============================================================================================================================================
cQryRPVH := " SELECT RV_DESCDET DESCR,RV_COD COD,RV_TIPOCOD,RV_CODFOL "
cQryRPVH += " 	,RD_VALOR  VLR ,RA_MAT,RA_RG,RA_PRINOME,RA_SECNOME,RA_SALARIO "
cQryRPVH += " 	,RA_CC, RA_DEPTO, SRA.R_E_C_N_O_ AS REGSRA, RA_FILIAL "
cQryRPVH += " FROM "+RETSQLNAME("SRA")+" SRA,"+RETSQLNAME("SRD")+" SRD "
cQryRPVH += " INNER JOIN "+RETSQLNAME("SRV")+" SRV ON "
If Empty(xFilial("SRV"))
	cQryRPVH += " 	RV_FILIAL = '"+xFilial("SRV")+"' "
Else
	cQryRPVH += " 	RV_FILIAL = RA_FILIAL "
EndIf
cQryRPVH += " 	AND RV_COD=RD_PD "
cQryRPVH += " 	AND RV_CODFOL IN ('0851','0852','0853') "
cQryRPVH += " 	AND SRV.D_E_L_E_T_='' "
cQryRPVH += " WHERE SRD.D_E_L_E_T_='' "
 
If !Empty(MV_PAR01)
	cQryRPVH += " 	AND "+RANGESX1("RA_FILIAL"	,MV_PAR01)  
EndIf
If !Empty(MV_PAR02)
	cQryRPVH += " 	AND "+RANGESX1("RA_CC"		,MV_PAR02)  
EndIf
If !Empty(MV_PAR03)
	cQryRPVH += " 	AND "+RANGESX1("RA_DEPTO"	,MV_PAR03)  
EndIf
If !Empty(MV_PAR04)
	cQryRPVH += " 	AND "+RANGESX1("RA_MAT"		,MV_PAR04)  
EndIf
If !Empty(MV_PAR05)
	cQryRPVH += " 	AND "+RANGESX1("RA_NOME"	,MV_PAR05)  
EndIf 

cQryRPVH += " 	AND RA_SITFOLH IN (" + MV_PAR06 + ")" 	

cQryRPVH += " 	AND RA_CATFUNC IN (" + MV_PAR07 + ")"  

If !Empty(MV_PAR09)
	cQryRPVH += " 	AND RA_PROCES='"+MV_PAR09+"' "  
EndIf 
If !Empty(MV_PAR10)
 	cQryRPVH += " 	AND RD_PERIODO='"+MV_PAR10+"' "  
EndIf
If !Empty(MV_PAR11)
 	cQryRPVH += " 	AND RD_SEMANA='"+MV_PAR11+"' "  
EndIf
If !Empty(MV_PAR12)
	cQryRPVH += " 	AND RD_ROTEIR='"+MV_PAR12+"' "  
EndIf
cQryRPVH += " 	AND RD_FILIAL=RA_FILIAL "
cQryRPVH += " 	AND RD_MAT=RA_MAT " 

//-- UNION
cQryRPVH += " UNION ALL "

cQryRPVH += " SELECT RV_DESCDET DESCR,RV_COD COD,RV_TIPOCOD,RV_CODFOL "
cQryRPVH += "    ,RC_VALOR  VLR ,RA_MAT,RA_RG,RA_PRINOME,RA_SECNOME,RA_SALARIO "
cQryRPVH += " 	,RA_CC, RA_DEPTO, SRA.R_E_C_N_O_ AS REGSRA, RA_FILIAL "
cQryRPVH += " FROM "+RETSQLNAME("SRA")+" SRA, " +RETSQLNAME("SRC")+" SRC "
cQryRPVH += " INNER JOIN "+RETSQLNAME("SRV")+" SRV ON "
If Empty(xFilial("SRV"))
	cQryRPVH += " 	RV_FILIAL = '"+xFilial("SRV")+"' "
Else
	cQryRPVH += " 	RV_FILIAL = RA_FILIAL "
EndIf
cQryRPVH += " 	AND RV_COD=RC_PD "
cQryRPVH += " 	AND RV_CODFOL IN ('0851','0852','0853') "
cQryRPVH += " 	AND SRV.D_E_L_E_T_='' "
cQryRPVH += " WHERE SRC.D_E_L_E_T_='' "

If !Empty(MV_PAR01)
	cQryRPVH += " 	AND "+RANGESX1("RA_FILIAL"	,MV_PAR01)  
EndIf
If !Empty(MV_PAR02)
	cQryRPVH += " 	AND "+RANGESX1("RA_CC"		,MV_PAR02)  
EndIf
If !Empty(MV_PAR03)
	cQryRPVH += " 	AND "+RANGESX1("RA_DEPTO"	,MV_PAR03)  
EndIf
If !Empty(MV_PAR04)
	cQryRPVH += " 	AND "+RANGESX1("RA_MAT"		,MV_PAR04)  
EndIf
If !Empty(MV_PAR05)
	cQryRPVH += " 	AND "+RANGESX1("RA_NOME"	,MV_PAR05)  
EndIf 
If !Empty(MV_PAR06)
 	cQryRPVH += " 	AND RA_SITFOLH IN (" + MV_PAR06 + ")" 	
EndIf
If !Empty(MV_PAR07)
 	cQryRPVH += " 	AND RA_CATFUNC IN (" + MV_PAR07 + ")"  
EndIf
If !Empty(MV_PAR09)
 	cQryRPVH += " 	AND RA_PROCES='"+MV_PAR09+"' "  
EndIf 
If !Empty(MV_PAR10)
	cQryRPVH += " 	AND RC_PERIODO='"+MV_PAR10+"' "  
EndIf
If !Empty(MV_PAR11)
	cQryRPVH += " 	AND RC_SEMANA='"+MV_PAR11+"' "  
EndIf
If !Empty(MV_PAR12)
	cQryRPVH += " 	AND RC_ROTEIR='"+MV_PAR12+"' "  
EndIf
cQryRPVH += " 	AND RC_FILIAL=RA_FILIAL "
cQryRPVH += " 	AND RC_MAT=RA_MAT "
//cQryRPVH += " ORDER BY RA_MAT,RV_COD "  
cQryRPVH += " ORDER BY 6,2 "  
cQryRPVH := ChangeQuery(cQryRPVH)

If Select("TRBRPVH")>0
	DbSelectArea("TRBRPVH")
	TRBRPVH->(DbCloseArea())
Endif
	
dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQryRPVH),"TRBRPVH",.F.,.T.)

If TRBRPVH->(!Eof())	
	Do While TRBRPVH->(!Eof()) 
		cMat		:= TRBRPVH->RA_MAT     
		cNome		:= Alltrim(TRBRPVH->RA_PRINOME)+" "+Alltrim(TRBRPVH->RA_SECNOME)  
		cDepto	:= TRBRPVH->RA_DEPTO
		cCCusto	:= TRBRPVH->RA_CC
		nCi		:= TRBRPVH->RA_RG
		nRegSRA	:= TRBRPVH->REGSRA
		cFilSRA	:= TRBRPVH->RA_FILIAL
		nSalMes	:= TRBRPVH->RA_SALARIO
		nSalBase	:= 0
		nVlrFun	:= 0
		nVlrEmp	:= 0
	
	 	Do While TRBRPVH->(!Eof()) .And. cMat==TRBRPVH->RA_MAT
	     	DO CASE
	  			CASE TRBRPVH->RV_CODFOL 	==	'0851'
	   			  nSalBase+=TRBRPVH->VLR
			   CASE TRBRPVH->RV_CODFOL 	==	'0852'
			        nVlrEmp+=TRBRPVH->VLR
			   CASE TRBRPVH->RV_CODFOL 	==	'0853'
			        nVlrFun+=TRBRPVH->VLR
			ENDCASE
	     	
			TRBRPVH->(DbSkip()) 
	   End     
	    nTFunEmp		:=	nVlrFun+nVlrEmp  
	    nVlrTSalMes	+=	nSalMes
	    nVlrTSalBase	+=	nSalBase
	    nVlrTFun		+=	nVlrFun 
	    nVlrTEmp		+=	nVlrEmp
	    nVlrTot			+=	nVlrFun+nVlrEmp 
	   
	    Aadd(aRPVH,{nNro,cNome,nCi,nSalBase,nVlrFun,nVlrEmp,nTFunEmp,cDepto,cCCusto,nRegSRA,cFilSRA,nSalMes})
	
	End	      
	If aReturn[8] == 1 // Ordem retornada pela funcao SetPrint
		aSort(aRPVH,,,{|x,y|x[11]+x[2]<Y[11]+y[2]}) // Filial + SobreNome + Nome 
	ElseIf aReturn[8] == 2
		aSort(aRPVH,,,{|x,y|x[11]+x[8]+x[2]<Y[11]+y[8]+y[2]}) // Filial + Depto + SobreNome + Nome
	ElseIf aReturn[8] == 3
		aSort(aRPVH,,,{|x,y|x[11]+x[9]+x[8]+x[2]<Y[11]+y[9]+y[8]+y[2]}) // Filial + CCusto + Depto + SobreNome + Nome
	Else
	//	MsgAlert("Ordem Desconhecida!!","Aten玢o")
	EndIf
	MsgRun(STR0007,STR0008, {||CursorWait(),RelRPVH(aRPVH),CursorArrow()})//Aguarde...#Processando RPVH
Else
	Alert(STR0035,STR0036)//"Nao foram encontrados dados de acordo com o parametro.","Atencao"  
EndIf

RestArea( aArea)
Return 
	
/*
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北
北谀哪哪哪哪履哪哪哪哪履哪哪哪履哪哪哪哪哪哪哪哪哪哪哪哪穆哪哪哪履哪哪哪哪目北
北矲uncao   � RelRPVH � Autor 砅aulo Eduardo             � Data � 19/12/08 潮�
北媚哪哪哪哪拍哪哪哪哪聊哪哪哪聊哪哪哪哪哪哪哪哪哪哪哪哪牧哪哪哪聊哪哪哪哪拇北
北矰escricao� Contem todo o detalhe do relatorio do Assegurado			   潮�
北媚哪哪哪哪拍哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪拇北
北� Uso     � TOTVS						                               潮�
北滥哪哪哪哪聊哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪馁北
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北
*/

Static Function RelRPVH(aRPVH)             
Local nCont:=0     ,nQtd:=0 
Local cChave := "" , cChaveAtu := ""

Private cNomEmp:="",cCGCEmp:=""
Private nLin	:= 0
Private nCol	:= 0
//DbSelectArea("SM0")
//Dbseek(cEmpAnt+cFilAnt)                 
oPrint:= TMSPrinter():New( cTitulo)
//oPrint := TMsPrinter():New(::cTitle,,,,,,::lPreview,cFile,(::nRemoteType == NO_REMOTE .or. ::cPrinterName == CONST_SEMIMPRESS),(::nDevice <> IMP_DISCO))
//谀哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪目
//砎erifica se ha impressora ativa conectada �
//滥哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪馁
If ! oPrint:IsPrinterActive() 
	oPrint:Setup()							//-- Escolhe a impressora	
	If ! oPrint:IsPrinterActive()	
		Help(" ",1,"NOPRINTGRA")		//-- Nao foi encontrada configuracao de impressora. ##Certifique-se de que as configura珲es da impressora est鉶 corretas ou se h� alguma impressora conectada.
		Return(Nil)
	Endif
Endif


//北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北//
//Modo de Impressao                                                           //
//oPrint:SetLandscape() - Impressao Paisagem                                  //
//oPrint:SetPortrait()  - Impressao Retrato                                   //
//北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北//
//oPrint:SetPortrait()
oPrint:SetLandscape()
//CabRPVH()       
//nLin+=100     

For nCont:=1 To Len(aRPVH)
	//-- Posiciona SRA
	SRA->(DbGoto(aRPVH[nCont][10]))
        
	//-- Controle de Quebra para op珲es 2 e 3 de ordena玢o
   If aReturn[8]==1			// Filial + SobreNome + Nome
   	cChaveAtu	:= aRPVH[nCont][11]
   ElseIf aReturn[8]==2		// Filial + Depto + SobreNome + Nome
   	cChaveAtu 	:= aRPVH[nCont][11] + aRPVH[nCont][8]    
		cDeptoAtu 	:= aRPVH[nCont][8]
   ElseIf aReturn[8]==3		// Filial + CCusto + Depto + SobreNome + Nome
   	cChaveAtu 	:= aRPVH[nCont][11] + aRPVH[nCont][9] + aRPVH[nCont][8]    
   	cCCustoAtu 	:= aRPVH[nCont][9]
		cDeptoAtu 	:= aRPVH[nCont][8]   
   EndIf
	If nCont == 1
		cChave 		:= cChaveAtu    
   	cCCustoAtu 	:= aRPVH[nCont][9]
		cDeptoAtu 	:= aRPVH[nCont][8]
		CabRPVH()       
		nLin+=100 
	EndIf		
   
	If nQtd>20 .Or. cChave != cChaveAtu
		oPrint:Box(nLin-50 ,1450,nLin+50,3150)  
		oPrint:Line(nLin-50,1800,nLin+50,1800)
		oPrint:Line(nLin-50,2150,nLin+50,2150)
		oPrint:Line(nLin-50,2500,nLin+50,2500)
	   	oPrint:Line(nLin-50,2850,nLin+50,2850)
		///////////////////////////////////////////////         
		oPrint:Say(nLin,nCol+1150 ,STR0021                               		  		,oArial10N)//SubTotais
		oPrint:Say(nLin,nCol+1460 ,Transform(nVlrSSalMes	,"@R 999,999,999.99")	,oArial10N)//SubTotal do Salarios Mensais
		oPrint:Say(nLin,nCol+1810 ,Transform(nVlrSSalBase	,"@R 999,999,999.99")	,oArial10N)//SubTotal do Salarios Base RPVH
		oPrint:Say(nLin,nCol+2160 ,Transform(nVlrSFun		,"@R 999,999,999.99")	,oArial10N)//SubTotal 1% Trabalhadores
		oPrint:Say(nLin,nCol+2510 ,Transform(nVlrSEmp		,"@R 999,999,999.99")	,oArial10N)//SubTotal 2% Empresa
		oPrint:Say(nLin,nCol+2830 ,Transform(nVlrSTot 		,"@R 999,999,999.99")	,oArial10N)//SubTotal 3% Total (Trabalhadores + Empresa)
      
		nLin+=100 
	 //	oPrint:Say(nLin,nCol+1000 ,STR0022,oArial10N)//<<<CONTINUA>>>
		oPrint:EndPage()	 
		oPrint:StartPage()	 
		CabRPVH()       
		nLin+=100  
		
		cChave 		:= cChaveAtu  
   	cCCusto	 	:= cCCustoAtu
		cDepto 		:= cDeptoAtu
		nQtd   		:= 0		 		  
	Endif     

	///////////////////////////////////////////////               
	oPrint:Box(nLin-50,nCol ,nLin+50,3150) 
	oPrint:Line(nLin-50,175 ,nLin+50, 175) 
	oPrint:Line(nLin-50,1190,nLin+50,1190)
	oPrint:Line(nLin-50,1450,nLin+50,1450)  
	oPrint:Line(nLin-50,1800,nLin+50,1800)
	oPrint:Line(nLin-50,2150,nLin+50,2150)
	oPrint:Line(nLin-50,2500,nLin+50,2500)
	oPrint:Line(nLin-50,2850,nLin+50,2850)
	///////////////////////////////////////////////    
	oPrint:Say(nLin,nCol+10   ,Transform(nCont,"@R 999999"),oArial9N)							//Sequencial
	oPrint:Say(nLin,nCol+105  ,aRPVH[nCont][2],oArial9N)									  		//Sobrenome e Nome
	oPrint:Say(nLin,nCol+1160 ,aRPVH[nCont][3],oArial10N)											//RG
	oPrint:Say(nLin,nCol+1460 ,Transform(aRPVH[nCont][12],"@R 999,999,999.99"),oArial10N)//Valor do Salario Mensal
	oPrint:Say(nLin,nCol+1810 ,Transform(aRPVH[nCont][4],"@R 999,999,999.99"),oArial10N)//Valor do Salario Base
	oPrint:Say(nLin,nCol+2160 ,Transform(aRPVH[nCont][5],"@R 999,999,999.99"),oArial10N)//Valor do 1% Trabalhador
	oPrint:Say(nLin,nCol+2510 ,Transform(aRPVH[nCont][6],"@R 999,999,999.99"),oArial10N)//Valor do 2% Empresa
	oPrint:Say(nLin,nCol+2830 ,Transform(aRPVH[nCont][7],"@R 999,999,999.99"),oArial10N)//Valor da 3% Total (Trabalhador + Empresa)
//  	oPrint:Say(nLin,nCol+660 ,Transform(aRPVH[nCont][8],"@!"),oArial10N)//
//  	oPrint:Say(nLin,nCol+460 ,Transform(aRPVH[nCont][9],"@!"),oArial10N)//
   nVlrSSalMes		+=	aRPVH[nCont][12]
   nVlrSSalBase	+=	aRPVH[nCont][4]
   nVlrSFun			+=	aRPVH[nCont][5]
   nVlrSEmp			+=	aRPVH[nCont][6]
   nVlrSTot			+=	aRPVH[nCont][7] 
   
	nQtd++
	nLin+=100                        
Next
If  nVlrSSalMes	<>	 nVlrTSalMes   .And. nVlrSTot 	<> nVlrTot 
////
	oPrint:Box(nLin-50 ,1450,nLin+50,3150)  
	oPrint:Line(nLin-50,1800,nLin+50,1800)
	oPrint:Line(nLin-50,2150,nLin+50,2150)
	oPrint:Line(nLin-50,2500,nLin+50,2500)
	oPrint:Line(nLin-50,2850,nLin+50,2850)
	///////////////////////////////////////////////         
	oPrint:Say(nLin,nCol+1150 ,STR0021                               		  		,oArial10N)//SubTotais
	oPrint:Say(nLin,nCol+1460 ,Transform(nVlrSSalMes	,"@R 999,999,999.99")	,oArial10N)//SubTotal do Salarios Mensais
	oPrint:Say(nLin,nCol+1810 ,Transform(nVlrSSalBase	,"@R 999,999,999.99")	,oArial10N)//SubTotal do Salarios Base RPVH
	oPrint:Say(nLin,nCol+2160 ,Transform(nVlrSFun		,"@R 999,999,999.99")	,oArial10N)//SubTotal 1% Trabalhadores
	oPrint:Say(nLin,nCol+2510 ,Transform(nVlrSEmp		,"@R 999,999,999.99")	,oArial10N)//SubTotal 2% Empresa
	oPrint:Say(nLin,nCol+2830 ,Transform(nVlrSTot 		,"@R 999,999,999.99")	,oArial10N)//SubTotal 3% Total (Trabalhadores + Empresa)
	nQtd++
	nLin+=100   
EndIf	
////
oPrint:Box(nLin-50 ,1450,nLin+50,3150)  
oPrint:Line(nLin-50,1800,nLin+50,1800)
oPrint:Line(nLin-50,2150,nLin+50,2150)
oPrint:Line(nLin-50,2500,nLin+50,2500)
oPrint:Line(nLin-50,2850,nLin+50,2850)
///////////////////////////////////////////////         
oPrint:Say(nLin,nCol+1100 ,STR0020                               		  		,oArial10N)//Totais
oPrint:Say(nLin,nCol+1460 ,Transform(nVlrTSalMes	,"@R 999,999,999.99")	,oArial10N)//Total do Salarios Mensais
oPrint:Say(nLin,nCol+1810 ,Transform(nVlrTSalBase	,"@R 999,999,999.99")	,oArial10N)//Total do Salarios Base RPVH
oPrint:Say(nLin,nCol+2160 ,Transform(nVlrTFun		,"@R 999,999,999.99")	,oArial10N)//Total 1% Trabalhadores
oPrint:Say(nLin,nCol+2510 ,Transform(nVlrTEmp		,"@R 999,999,999.99")	,oArial10N)//Total 2% Empresa
oPrint:Say(nLin,nCol+2830 ,Transform(nVlrTot 		,"@R 999,999,999.99")	,oArial10N)//Total 3% Total (Trabalhadores + Empresa)


nQtd++



oPrint:EndPage()                                    
If aReturn[5]==1
	MsgRun(STR0026,STR0007, {||CursorWait(),oPrint:Preview(),CursorArrow()})//Carregando#Aguarde... 
Else
	MsgRun(STR0027,STR0007, {||CursorWait(),oPrint:Print(),CursorArrow()})//Imprimindo#Aguarde... 
Endif
  				
Return           
/*
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北
北谀哪哪哪哪履哪哪哪哪履哪哪哪履哪哪哪哪哪哪哪哪哪哪哪哪穆哪哪哪履哪哪哪哪目北
北矲uncao   � CabRPVH  � Autor 砅aulo Eduardo             � Data � 19/12/08 潮�
北媚哪哪哪哪拍哪哪哪哪聊哪哪哪聊哪哪哪哪哪哪哪哪哪哪哪哪牧哪哪哪聊哪哪哪哪拇北
北矰escricao� Cabecalho do relatorio RPVH      					       潮�
北媚哪哪哪哪拍哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪拇北
北� Uso     � TOTVS						                               潮�
北滥哪哪哪哪聊哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪馁北
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北
*/
Static Function CabRPVH
//Local cPagOrd:=STR0018//"RPVH"
//oPrint:Saybitmap(010,010,cStartPath+"RPVH"+".bmp",2500,3400) 
nVlrSSalMes		:=	0
nVlrSSalBase	:=	0
nVlrSFun			:=	0
nVlrSEmp			:=	0
nVlrSTot			:=	0 
nLin				:=	100
nCol				:=	80 
cTime				:= TIME()  
cPgm				:=	"SIGA/GPER855/v.P10"  

DbSelectArea("SM0")
Dbseek(cEmpAnt+cFilAnt) 
cNomEmp	:=IIF(EMPTY(SM0->M0_NOMECOM),SM0->M0_NOME,SUBSTR(SM0->M0_NOMECOM,1,30))
cCNPJ		:=SM0->M0_CGC
cEndEmp	:=SM0->M0_ENDCOB

dbSelectArea("CTT")
dbSetOrder(1)
IF CTT->(dbSeek(xFilial("CTT",cFilAnt) + cCCustoAtu))
    cDesCC := CTT->CTT_DESC01
EndIf  

DbSelectArea("SQB")
SQB->(DbSetOrder(RetOrder("SQB","QB_FILIAL+QB_DEPTO")))
SQB->(DbGoTop())
If DbSeek(xFilial("SQB")+cDeptoAtu)
	cDesDpto:=SQB->QB_DESCRIC  
EndIf 

nPag+= 1 
oPrint:Say(nLin+20,3020     	,"Pag.: " + Transform(nPag," 9,999") ,	oArial10N)// "Pag." 
nLin+=90  
                        
oPrint:Say(nLin,nCol+10       ,cPgm  ,oArial10N)// PRW   
oPrint:Say(nLin,2750    	   ,STR0024,oArial10N)// "Data Emissao :" 
oPrint:Say(nLin,3020       	,DTOC(dDataDia),oArial10N)// Data Emissao
nLin+=30  

oPrint:Say(nLin+20,nCol+10    ,cTime  ,	oArial10N)// Horas
oPrint:Say(nLin,nCol+1350     ,STR0009,   oArial14N)// Pagamento do RPVH 
oPrint:Say(nLin+20,2750     	,STR0025,	oArial10N)// "Data Ref. :" 
oPrint:Say(nLin+20,3020     	,Substr(MV_PAR08,1,2) + "/" + Substr(MV_PAR08,3,4),oArial10N)//Mes/Ano   

nLin+=150  

//oPrint:Say(nLin,nCol+1340     ,Substr(MV_PAR08,5,2) + "/" + Substr(MV_PAR08,1,4),oArial14N)//Mes/Ano
//nLin+=150 
oPrint:Say(nLin,nCol+100      ,cNomEmp,oArial11N)//Empresa  
oPrint:Say(nLin,nCol+1200  	,STR0034,oArial11N)// "No. R.I.F. :" 
oPrint:Say(nLin,nCol+1400  	,Transform(cCNPJ,"@R 999.999.999.999-99"),oArial11N)//c骴igo CGC  

/////////////////////////////////////////////// 
nLin+=80 

If aReturn[8]==2		// Filial + Depto + SobreNome + Nome
 	oPrint:Say(nLin,nCol+100      , STR0022   + ": "						,oArial11N)
  	oPrint:Say(nLin,nCol+250 	   , cDeptoAtu	+ " - " 	+ cDesDpto		,oArial11N)
ElseIf aReturn[8]==3		// Filial + CCusto + Depto + SobreNome + Nome
  	oPrint:Say(nLin,nCol+100      , STR0023 	+ ": " 	 					,oArial11N)
  	oPrint:Say(nLin,nCol+270     	, cCCustoAtu+ " - " 	+ cDesCC 		,oArial11N)	   
  	oPrint:Say(nLin,nCol+1200    	, STR0022 	+ ": " 						,oArial11N)    
  	oPrint:Say(nLin,nCol+1350     , cDeptoAtu + " - " 	+ cDesDpto		,oArial11N)
EndIf

cMesAno:=Substr(MV_PAR08,1,4)+Substr(MV_PAR08,5,2)  
/////////////////////////////////////////////// 
nLin+=100                 
///////////////////////////////////////////////               
oPrint:Box(nLin-150 ,2150,nLin+50,3150)
oPrint:Line(nLin-150,2500,nLin+50,2500)
oPrint:Line(nLin-150,2850,nLin+50,2850) 
/////////////////////////////////////////////////// 
oPrint:Say(nLin-150,2230      ,STR0011,oArial10N)// Aporte 
oPrint:Say(nLin-100,2230      ,STR0012,oArial10N)// Trabalhador
oPrint:Say(nLin-150,2600      ,STR0011,oArial10N)// Aporte
oPrint:Say(nLin-100,2600      ,STR0013,oArial10N)// Empresa  
oPrint:Say(nLin-100,2980      ,STR0014,oArial10N)// Total
/////////////////////////////////////////////////// 

oPrint:Box(nLin-50,nCol ,nLin+50,3150) 
oPrint:Line(nLin-50,175 ,nLin+50, 175) 
oPrint:Line(nLin-50,1190,nLin+50,1190)
oPrint:Line(nLin-50,1450,nLin+50,1450)  
oPrint:Line(nLin-50,1800,nLin+50,1800)
oPrint:Line(nLin-50,2150,nLin+50,2150)
oPrint:Line(nLin-50,2500,nLin+50,2500)
oPrint:Line(nLin-50,2850,nLin+50,2850)  

///////////////////////////////////////////////
oPrint:Say(nLin,90        ,STR0028,oArial11N)//"No"
oPrint:Say(nLin,180       ,STR0010,oArial11N)//"Nome e Sobrenome"
oPrint:Say(nLin,1290      ,STR0015,oArial11N)//"C.I."
oPrint:Say(nLin,1490      ,STR0016,oArial11N)//"Salario Mensal"
oPrint:Say(nLin-30,1820   ,STR0032,oArial10N)//"Base de Calculo" 
oPrint:Say(nLin+10,1900   ,STR0033,oArial10N)//"RPVH" 
oPrint:Say(nLin,2300      ,STR0017,oArial11N)//"1%" 
oPrint:Say(nLin,2650      ,STR0018,oArial11N)//"2%"
oPrint:Say(nLin,3000      ,STR0019,oArial11N)//"3%"

Return  

/*
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北
北谀哪哪哪哪履哪哪哪哪履哪哪哪履哪哪哪哪哪哪哪哪哪哪哪哪穆哪哪哪履哪哪哪哪目北
北矲uncao   � RangeSX1  � Autor 矼arcos Kato             � Data � 28/11/08 潮�
北媚哪哪哪哪拍哪哪哪哪聊哪哪哪聊哪哪哪哪哪哪哪哪哪哪哪哪牧哪哪哪聊哪哪哪哪拇北
北矰escricao� Tratamento do Range do Sx1 para ser utilizado na Query       潮�
北媚哪哪哪哪拍哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪拇北
北� Uso     � Microsiga		  prgm: GPER850.prw                             潮�
北滥哪哪哪哪聊哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪馁北
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北
*/
/*
Function RangeSx1(cCampo,cParSX1)
Local nCaract:=0
Local cConteudo:=""

If At("-",cParSX1)>0//Intervalo
	cConteudo:=" "+cCampo+" BETWEEN ' "
 	For nCaract:=1 To Len(cParSX1)       
		If Substr(cParSX1,nCaract,1)=="-"
			cConteudo+="' AND '"
		Else
			cConteudo+=Substr(cParSX1,nCaract,1)
    	Endif
    Next	           
    cConteudo+="' "
ElseIf  At(";",cParSX1)>0//Contido
	cConteudo:=" "+cCampo+" IN ('"
 	For nCaract:=1 To Len(Alltrim(cParSX1))       
		If Substr(cParSX1,nCaract,1)==";"
			cConteudo+="','"
		Else
			cConteudo+=Substr(cParSX1,nCaract,1)
    	Endif
    Next	           
    If Substr(cConteudo,Len(cConteudo)-1,2)==",'"
    	cConteudo:=Substr(cConteudo,1,Len(cConteudo)-2)+") "
    Else
	    cConteudo+="') "
	Endif    
Else               
	cConteudo:=" "+cCampo+" = '"+cParSx1+"' "
Endif	
Return cConteudo
*/         