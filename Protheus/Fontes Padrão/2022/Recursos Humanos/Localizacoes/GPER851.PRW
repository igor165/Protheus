#INCLUDE "PROTHEUS.CH"                       
#INCLUDE "RWMAKE.CH"  
#INCLUDE "GPER851.CH"
#INCLUDE "TOPCONN.CH"

/*
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao   ³ GPER851 ³ Autor ³Marcos Kato                      ³ Data ³ 27/11/08  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao³ relatório Participacao de retirada do trabalhador              	   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Programador ³ Data     ³   BOPS    ³  Motivo da Alteracao                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Tiago Malta ³15/04/2011³005374/2011³Criado imagem jpg optimizando a impressão   ³±±
±±³            ³          ³           ³ e acertado as posições da impressão.       ³±±
±±³Tiago Malta ³11/05/2011³009206/2011³Tratamento para a versao p11.               ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±³ Uso     ³ Microsiga						                                       ³±±
±±ÀÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
*/
Function GPER851()
Local cString	:= "SRA"
Local nomeProg 	:= "GPER851"
Local cPerg     := "GPER851   "
Local cDesc1	:=STR0001//"Relatorio do Assegurado" 
Local cDesc2 	:=STR0007//"Sera  impresso de acordo com os parametros solicitados pelo"
Local cDesc3 	:=STR0008//"usuario."
Local aArea		:= GetArea()
Local cTamanho	:="P"
Private oPrint   
Private cTitulo 	:= STR0001//"Relatorio Participação de retirada do trabalhador" 
Private aReturn 	:= {STR0009, 1,STR0010, 2, 1, 1, "",1 }//Zebrado#Administracao
//±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±//
//Fontes de Impressao                                                         //
//±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±//
Private oArial12N	:= TFont():New("Arial",12,12,,.T.,,,,.F.,.F.)
Private oArial14N	:= TFont():New("Arial",14,14,,.T.,,,,.F.,.F.)
Private oArial18N	:= TFont():New("Arial",18,16,,.T.,,,,.F.,.F.)
Private cStartPath	:= GetSrvProfString("Startpath","")

Pergunte(cPerg,.F.)
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Envia controle para a funcao SETPRINT                        ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
wnrel := "GPER851"

wnrel:=SetPrint(cString,wnrel,cPerg,@cTitulo,cDesc1,cDesc2,cDesc3,.F.,,,cTamanho,,.F.)

If nLastKey = 27
	Return
Endif

SetDefault(aReturn,cString)

If nLastKey = 27
	Return
Endif

oPrint:= TMSPrinter():New( cTitulo )
//±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±//
//Modo de Impressao                                                           //
//oPrint:SetLandscape() - Impressao Paisagem                                  //
//oPrint:SetPortrait()  - Impressao Retrato                                   //
//±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±//
oPrint:SetPortrait()
MsgRun(STR0002,STR0003, {||CursorWait(),RelF1403(),CursorArrow()})//Processando dados do trabalhador#Aguarde...          
	
Return Nil
/*
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao   ³ RelF1403 ³ Autor ³Marcos Kato              ³ Data ³ 22/07/08 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao³ Contem todo o detalhe do relatorio do Assegurado			   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso     ³ Microsiga						                               ³±±
±±ÀÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
*/

Static Function RelF1403()             
Local cNomEmp	:="",cCGCEmp	:="",cQryF1403	:="",cRGFun		:="",cNAFun   	:="",cNomFun	:=""
Local cTipoRes	:="",cSitFol	:="",cCargo 	:="",cDCargo	:="",cAnoMes  	:="",cCatFun	:=""
Local cProces	:="",cPeriod	:="",cFilSra	:="",cCC    	:="",cDepto 	:="",cMat   	:=""
Local cCateg	:="",cSituac    :="",cNome		:="",cDtAAdm	:="",cDtMAdm	:="",cDtDAdm	:="",cDtADem	:=""
Local cDtMDem	:="",cDtDDem	:=""
Local nAsseg 	:=0 ,nSalSem:=0, nCont :=0
Local aEmpCor   :={}
Local nPos      := 0
Local nPosRes   := 0
Local aTabRes   := {}
Private nLin	:= 0
Private nCol	:= 0
//================================
//mv_par01 - Mes/Ano Demissao
//================================

cProces:=MV_PAR01          
cFilSra:=IIF(EMPTY(MV_PAR02),"",RANGESX1("RA_FILIAL",MV_PAR02))
cCC    :=IIF(EMPTY(MV_PAR03),"",RANGESX1("RA_CC"    ,MV_PAR03))
cDepto :=IIF(EMPTY(MV_PAR04),"",RANGESX1("RA_DEPTO" ,MV_PAR04))
cMat   :=IIF(EMPTY(MV_PAR05),"",RANGESX1("RA_MAT"   ,MV_PAR05))
cSituac:="'"
For nCont:=1 To Len(MV_PAR06)
	cSituac+=Substr(MV_PAR06,nCont,1)+"','"
Next                                  
cSituac:=Substr(cSituac,1,Len(cSituac)-2)
If Empty(cSituac)
	cSituac:="' '"
Endif
cCateg:="'"
For nCont:=1 To Len(MV_PAR07)
	cCateg+=Substr(MV_PAR07,nCont,1)+"','"
Next                                  
cCateg:=Substr(cCateg,1,Len(cCateg)-2)
If Empty(cCateg)
	cCateg:="' '"
Endif
cNome  :=IIF(EMPTY(MV_PAR08),"",RANGESX1("RA_NOME"  ,MV_PAR08))
cAnoMes:=MV_PAR09
      
//==============================================================================================================================================
//==================================Processando dados do Registro Segurado======================================================================                                                                              
//==============================================================================================================================================
cQryF1403:="SELECT RA_FILIAL,RA_MAT,RA_NOME,RA_RG,RA_PRINOME,RA_SECNOME,RA_NASC,RA_SITFOLH,RA_CATFUNC,RA_SEXO,RA_DEMISSA,RA_ADMISSA,RA_SALARIO,RA_CARGO "
cQryF1403+="FROM "+RETSQLNAME("SRA")+" SRA "
cQryF1403+="WHERE SRA.D_E_L_E_T_='' "
cQryF1403+="AND SUBSTRING(RA_DEMISSA,1,6) ='"+Substr(cAnoMes,1,4)+Substr(cAnoMes,5,2)+"' "
cQryF1403+="AND RA_PROCES = '"+cProces+"' "
If !Empty(cFilSra)
	cQryF1403+="AND "+cFilSra
Endif
If !Empty(cCC)
	cQryF1403+="AND "+cCC
Endif	
If !Empty(cDepto)
	cQryF1403+="AND "+cDepto
Endif	
If !Empty(cMat)
	cQryF1403+="AND "+cMat
Endif	
If !Empty(cNome)
	cQryF1403+="AND "+cNome
Endif
cQryF1403+="AND RA_SITFOLH IN ("+cSituac+") "
cQryF1403+="AND RA_CATFUNC IN ("+cCateg+") "

cQryF1403 := ChangeQuery(cQryF1403)

If Select("TRBF1403")>0
	DbSelectArea("TRBF1403")
	TRBF1403->(DbCloseArea())
Endif

dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQryF1403),"TRBF1403",.F.,.T.)
CabF143()
If TRBF1403->(!Eof())                                 
	Do While TRBF1403->(!Eof())
	
		aEmpCor     := FWLoadSM0()
		nPos        := aScan( aEmpcor , { |x| x[1] == cEmpant .and. x[2] == TRBF1403->RA_FILIAL  } )
		
		IF nPos > 0
			cCGCEmp:=Substr(Alltrim(aEmpCor[nPos][SM0_CGC]),1,9)
			cNomEmp:=IIF(EMPTY(aEmpCor[nPos][SM0_NOME]),aEmpCor[nPos][SM0_NOMRED],aEmpCor[nPos][SM0_NOME])
		ENDIF 
                            
		cRGFun	:=Substr(TRBF1403->RA_RG,2,8)
		cNAFun  :=Iif(Len(Alltrim(TRBF1403->RA_RG))==9,Alltrim(TRBF1403->RA_RG),Strzero(0,9-len(Alltrim(TRBF1403->RA_RG)))+Alltrim(TRBF1403->RA_RG))
	    cNomFun	:=TRBF1403->RA_NOME                                     
   		cDtAAdm:=Substr(TRBF1403->RA_ADMISSA	,3,2)//Ano de Admissao
		cDtMAdm:=Substr(TRBF1403->RA_ADMISSA	,5,2)//Mes de Admissao
		cDtDAdm:=Substr(TRBF1403->RA_ADMISSA	,7,2)//Dia de Admissao
		cDtADem:=Substr(TRBF1403->RA_DEMISSA	,3,2)//Ano de Nascimento
		cDtMDem:=Substr(TRBF1403->RA_DEMISSA	,5,2)//Mes de Nascimento
		cDtDDem:=Substr(TRBF1403->RA_DEMISSA	,7,2)//Dia de Nascimento
		nSalSem:=Transform((TRBF1403->RA_SALARIO/30)*7,"@E 999,999,999.99")
		cSitFol:=TRBF1403->RA_SITFOLH							//Situacao
		cCatFun:=TRBF1403->RA_CATFUNC							//Categoria
		cCargo :=TRBF1403->RA_CARGO								//Cargo
		cDCargo:=FDESC("SQ3",TRBF1403->RA_CARGO,"Q3_DESCSUM")	//Descricao do cargo
		If cSitFol=="D"
			DbSelectArea("SRG")
			SRG->(DbSetOrder(1))
			If DbSeek(xFilial("SRG")+TRBF1403->RA_MAT)
				cTipoRes:=SRG->RG_TIPORES             
				fRetTab(@aTabRes,"S005",,,dDataBase,,.t.)
				
				nPosRes	:= Ascan(aTabRes,{ |X| X[5] == cTipoRes })
				if nPosRes > 0
						If aTabRes[nPosRes][15]=="1"
							cSitFol:="D"
						ElseIf aTabRes[nPosRes][15]=="2"
							cSitFol:="R"						    
						ElseIf aTabRes[nPosRes][15]=="3"
							cSitFol:="M"						    
						Endif
				Endif
			ElseIf !Empty(cSitFol)
				If cCatFun=="1"//Jubilado		
					cSitFol:="J"
				ElseIf cCatFun=="2"//Pensionado		
					cSitFol:="P"				
				Endif	
			Endif
		Endif
		TRBF1403->(DbSkip()) 
		If nAsseg>0
			oPrint:EndPage()	
			oPrint:StartPage()
			CabF143()
		Endif
		nAsseg++
		oPrint:Say(nLin,nCol  	  ,cNomEmp ,oArial12N)
		oPrint:Say(nLin,nCol+1360 ,Substr(cCgcEmp,1,1) ,oArial12N)
		oPrint:Say(nLin,nCol+1425 ,Substr(cCgcEmp,2,1) ,oArial12N)
		oPrint:Say(nLin,nCol+1495 ,Substr(cCgcEmp,3,1) ,oArial12N)
		oPrint:Say(nLin,nCol+1560 ,Substr(cCgcEmp,4,1) ,oArial12N)
		oPrint:Say(nLin,nCol+1635 ,Substr(cCgcEmp,5,1) ,oArial12N)
		oPrint:Say(nLin,nCol+1695 ,Substr(cCgcEmp,6,1) ,oArial12N)
		oPrint:Say(nLin,nCol+1765 ,Substr(cCgcEmp,7,1) ,oArial12N)
		oPrint:Say(nLin,nCol+1830 ,Substr(cCgcEmp,8,1) ,oArial12N)
		oPrint:Say(nLin,nCol+1890 ,Substr(cCgcEmp,8,1) ,oArial12N)		
	
		nLin+=210        
		oPrint:Say(nLin,nCol   	  ,cNomFun,oArial12N)//Nome do Funcionario ou Assegurado                                  
		oPrint:Say(nLin,nCol+1360 ,cNAFun ,oArial12N)//Numero de Assegurado			
		nLin+=220         			
		oPrint:Say(nLin,nCol      ,cDtDAdm,oArial12N)//Dia da Admissao do Assegurado						
		oPrint:Say(nLin,nCol+130  ,cDtMAdm,oArial12N)//Mes da Admissao do Assegurado			
		oPrint:Say(nLin,nCol+270  ,cDtAAdm,oArial12N)//Ano da Admissao do Assegurado
		oPrint:Say(nLin,nCol+450  ,nSalSem,oArial12N)//Salario Semanal
		oPrint:Say(nLin,nCol+785  ,cDCargo,oArial12N)//Descricao do cargo			
		oPrint:Say(nLin,nCol+1205 ,cCargo ,oArial12N)//Cargo			
		oPrint:Say(nLin,nCol+1450 ,cDtDDem,oArial12N)//Dia da Demissao do Assegurado						
		oPrint:Say(nLin,nCol+1585 ,cDtMDem,oArial12N)//Mes da Demissao do Assegurado			
		oPrint:Say(nLin,nCol+1720 ,cDtADem,oArial12N)//Ano da Demissao do Assegurado
		nLin+=225                        
		If cSitFol=="D"//Despedido*
			oPrint:Say(nLin,nCol+300  ,'X' ,oArial12N)
   		ElseIf cSitFol=="P"//Pensionado
   			oPrint:Say(nLin,nCol+860  ,'X' ,oArial12N)
   		Endif
		nlin+=130
  		If cSitFol=="R"//Renuncia*
			oPrint:Say(nLin,nCol+300  ,'X' ,oArial12N)
 		ElseIf cSitFol=="T"//Transferido
			oPrint:Say(nLin,nCol+860  ,'X' ,oArial12N)
		Endif	
		nlin+=130
   		If cSitFol=="J"//Jubilado
			oPrint:Say(nLin,nCol+300  ,'X' ,oArial12N)
   		ElseIf cSitFol=="M"//falecimento*
			oPrint:Say(nLin,nCol+860  ,'X' ,oArial12N)
   		Endif	
	End
	oPrint:EndPage()
	If aReturn[5]==1
		MsgRun(STR0004,STR0003, {||CursorWait(),oPrint:Preview(),CursorArrow()})//Carregando Layout#Aguarde...  				
	Endif
Else
    Aviso(STR0006,STR0005 ,{ "OK" } )//"Atencao"#"Nao ha informacoes para serem geradas.Verifique os parametros"		
Endif

Return           

/*
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao   ³ CabF143  ³ Autor ³Marcos Kato              ³ Data ³ 28/11/08 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao³ Cabecalho do relatorio assegurado   					       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso     ³ Microsiga						                               ³±±
±±ÀÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
*/

Static Function CabF143
oPrint:Saybitmap(200,210,cStartPath+"F1403"+".jpg",2000,2000)  
nCol:=260
nLin:=600
Return                            