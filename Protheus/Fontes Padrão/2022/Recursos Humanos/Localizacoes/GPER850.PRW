#INCLUDE "PROTHEUS.CH"                       
#INCLUDE "RWMAKE.CH"  
#INCLUDE "GPER850.CH"
#INCLUDE "TOPCONN.CH"
/*
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北
北谀哪哪哪哪履哪哪哪哪履哪哪哪履哪哪哪哪哪哪哪哪哪哪哪哪穆哪哪哪履哪哪哪哪哪哪哪哪目北
北矲uncao   � GPER850 � Autor 矼arcos Kato               �      � Data 	  27/11/08 潮�
北媚哪哪哪哪拍哪哪哪哪聊哪哪哪聊哪哪哪哪哪哪哪哪哪哪哪哪牧哪哪哪聊哪哪哪哪哪哪哪哪拇北
北矰escricao� relat髍io de registro do assegurado para envio ao SSO.               潮�
北媚哪哪哪哪拍哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪拇北
北砅rogramador � Data     �   BOPS    �  Motivo da Alteracao                       潮�
北媚哪哪哪哪哪呐哪哪哪哪哪拍哪哪哪哪哪拍哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪拇北
北砊iago Malta �15/04/2011�005374/2011矯riado imagem jpg optimizando a impress鉶   潮�
北�            �          �           � e acertado as posi珲es da impress鉶.       潮�
北砊iago Malta �11/05/2011�009206/2011砊ratamento para a versao p11.               潮�
北滥哪哪哪哪哪牧哪哪哪哪哪聊哪哪哪哪哪聊哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪馁北
北� Uso     � Microsiga						                                       潮�
北滥哪哪哪哪聊哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪馁北
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北
*/
Function GPER850()            
Local cString		:= "SRA"
Local nomeProg 		:= "GPER850"
Local cPerg     	:= "GPER850"
Local cDesc1		:=STR0001//"Relatorio do Assegurado" 
Local cDesc2 		:=STR0010//"Sera� impresso de acordo com os parametros solicitados pelo"
Local cDesc3 		:=STR0011//"usuario."
Local aArea			:= GetArea()
Local cTamanho		:="P"
Private oPrint
Private cTitulo 	:= STR0001//"Relatorio do Assegurado" 
Private aReturn 	:= {STR0012, 1,STR0013, 2, 1, 1, "",1 }//Zebrado#Administracao
//北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北//
//Fontes de Impressao                                                         //
//北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北//
Private oArial10N	:= TFont():New("Arial",10,10,,.T.,,,,.F.,.F.)
Private oArial22N	:= TFont():New("Arial",22,14,,.T.,,,,.F.,.F.)
Private cStartPath	:= GetSrvProfString("Startpath","")


Pergunte(cPerg,.F.)
//谀哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪目
//� Envia controle para a funcao SETPRINT                        �
//滥哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪馁
wnrel := "GPER850"

wnrel:=SetPrint(cString,wnrel,cPerg,@cTitulo,cDesc1,cDesc2,cDesc3,.F.,,,cTamanho,,.F.)

If nLastKey = 27
	Return
Endif

SetDefault(aReturn,cString)

If nLastKey = 27
	Return
Endif

MsgRun(STR0002,STR0003, {||CursorWait(),RelF1402(),CursorArrow()})//Processando dados do assegurado#Aguarde...

RestArea( aArea)
Return
/*
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北
北谀哪哪哪哪履哪哪哪哪履哪哪哪履哪哪哪哪哪哪哪哪哪哪哪哪穆哪哪哪履哪哪哪哪目北
北矲uncao   � RelF1402 � Autor 矼arcos Kato              � Data � 22/07/08 潮�
北媚哪哪哪哪拍哪哪哪哪聊哪哪哪聊哪哪哪哪哪哪哪哪哪哪哪哪牧哪哪哪聊哪哪哪哪拇北
北矰escricao� Contem todo o detalhe do relatorio do Assegurado			   潮�
北媚哪哪哪哪拍哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪拇北
北� Uso     � Microsiga						                               潮�
北滥哪哪哪哪聊哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪馁北
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北
*/

Static Function RelF1402()             
Local cNomEmp:="",cCGCEmp:="",cQryF1402:=""
Local cRGFun :="",cNAFun :="",cNomFun  :="",cDomici:="",cMatAss:=""
Local cSitFol:="",cCargo :="",cDepart  :="",cDCargo:="",cSexo  :="" 
Local cFilSra:="",cCC	 :="",cDepto   :="",cMat   :="",cNome  :="",cCatFun:=""
Local cDtANas:="",cDtMNas:="",cDtDNas  :="",cDtAAdm:="",cDtMAdm:="",cDtDAdm:=""
Local lNacVen:=.F.,lHabMot:=.F.
Local nAsseg :=0 ,nDep   :=0,nSalSem:=0, nCont :=0
Local aDepFun:={}
Local aEmpCor := {}
Local nPos    := 0
Private nCateg  := 0,nTipRel:= 0
Private nLin	:= 0,nCol	:= 0
//================================
//mv_par01 - Processo
//mv_par02 - Filial
//mv_par03 - Centro de Custo
//mv_par04 - Departamento
//mv_par05 - matricula  
//mv_par06 - Categoria
//mv_par07 - Situacao
//mv_par08 - Nome
//mv_par09 - Tipo de Relatorio
//================================
cProces:=MV_PAR01
cFilSra:=IIF(EMPTY(MV_PAR02),"",RANGESX1("RA_FILIAL",MV_PAR02))
cCC    :=IIF(EMPTY(MV_PAR03),"",RANGESX1("RA_CC"    ,MV_PAR03))
cDepto :=IIF(EMPTY(MV_PAR04),"",RANGESX1("RA_DEPTO" ,MV_PAR04))
cMat   :=IIF(EMPTY(MV_PAR05),"",RANGESX1("RA_MAT"   ,MV_PAR05))
nCateg :=MV_PAR06
cSitFol:="'"
For nCont:=1 To Len(Alltrim(MV_PAR07))
	cSitFol+=Substr(MV_PAR07,nCont,1)+"','"
Next                                  
cSitFol:=Substr(cSitFol,1,Len(cSitFol)-2)
If Empty(cSitFol)
	cSitFol:="' '"
Endif
cNome  :=IIF(EMPTY(MV_PAR08),"",RANGESX1("RA_NOME"  ,MV_PAR08))
nTipRel:=MV_PAR09

//==============================================================================================================================================
//==================================Processando dados do Registro Segurado======================================================================                                                                              
//==============================================================================================================================================
cQryF1402:="SELECT RA_FILIAL,RA_MAT,RA_NOME,RA_RG,RA_DEPTO,RA_PRINOME,RA_SECNOME,RA_NASC,RA_SITFOLH,RA_SEXO,RA_NACIONA,RA_ADMISSA,RA_SALARIO, "
cQryF1402+="RA_HABILMT,RA_ADMISSA,RA_CATFUNC,RA_CARGO,RA_ENDEREC,RA_COMPLEM,RA_BAIRRO,RB_MAT,RB_RG,RB_SEXO,RB_NOME,RB_SECNOME,RB_DTNASC, "
cQryF1402+="CASE RB_GRAUPAR "
cQryF1402+="WHEN 'F' THEN '"+STR0004+"' "//Filhos
cQryF1402+="WHEN 'C' THEN '"+STR0005+"'	" //Conjuge
cQryF1402+="ELSE '"+STR0006+"' "//Outros
cQryF1402+="END RB_GRAUPAR "
cQryF1402+="FROM "+RETSQLNAME("SRA")+" SRA "
cQryF1402+="LEFT JOIN "+RETSQLNAME("SRB")+" SRB ON "
cQryF1402+="RA_FILIAL=RB_FILIAL "
cQryF1402+="AND RA_MAT=RB_MAT "
cQryF1402+="AND SRB.RB_TIPSSO='1' "
cQryF1402+="AND SRB.D_E_L_E_T_='' "
cQryF1402+="WHERE SRA.D_E_L_E_T_='' "
cQryF1402+="AND RA_PROCES = '"+cProces+"' "
If !Empty(cFilSra)
	cQryF1402+="AND "+cFilSra
Endif
If !Empty(cCC)
	cQryF1402+="AND "+cCC
Endif	
If !Empty(cDepto)
	cQryF1402+="AND "+cDepto
Endif	
If !Empty(cMat)
	cQryF1402+="AND "+cMat
Endif	
If !Empty(cNome)
	cQryF1402+="AND "+cNome
Endif
If nCateg==1
	cQryF1402+="AND RA_CATFUNC ='1' "//Pensionista
ElseIf nCateg==2
	cQryF1402+="AND RA_CATFUNC ='2' "//Aposentado
ElseIf nCateg==3
    cQryF1402+="AND RA_CATFUNC IN ('1','2') "//Ambos(Pensionado/Aposentado)     
ElseIf nCateg==4
	cQryF1402+="AND RA_CATFUNC NOT IN ('1','2') "//Nao imprime Pensionado e aposentado        
Endif      
cQryF1402+="AND RA_SITFOLH IN ("+cSitFol+")



cQryF1402 := ChangeQuery(cQryF1402)

If Select("TRBF1402")>0
	DbSelectArea("TRBF1402")
	TRBF1402->(DbCloseArea())
Endif

dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQryF1402),"TRBF1402",.F.,.T.)
If TRBF1402->(!Eof())                                 
	oPrint:= TMSPrinter():New( cTitulo )
	//北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北//
	//Modo de Impressao                                                           //
	//oPrint:SetLandscape() - Impressao Paisagem                                  //
	//oPrint:SetPortrait()  - Impressao Retrato                                   //
	//北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北//
	oPrint:SetPortrait()
	CabF142()
	Do While TRBF1402->(!Eof())
	   
		aEmpCor     := FWLoadSM0()
		nPos        := aScan( aEmpcor , { |x| x[1] == cEmpant .and. x[2] == TRBF1402->RA_FILIAL  } )
		
		IF nPos > 0
			cCGCEmp:=Substr(Alltrim(aEmpCor[nPos][SM0_CGC]),1,9)
			cNomEmp:=IIF(EMPTY(aEmpCor[nPos][SM0_NOME]),aEmpCor[nPos][SM0_NOMRED],aEmpCor[nPos][SM0_NOME])
		ENDIF
		
		cMatAss:=TRBF1402->RA_MAT                                                                       
		
		Do While TRBF1402->(!Eof()).And.TRBF1402->RA_MAT==cMatAss
			cRGFun	:=Substr(TRBF1402->RA_RG,2,8)
			cNAFun  :=Iif(Len(Alltrim(TRBF1402->RA_RG))==9,Alltrim(TRBF1402->RA_RG),Strzero(0,9-len(Alltrim(TRBF1402->RA_RG)))+Alltrim(TRBF1402->RA_RG))
		    cNomFun	:=TRBF1402->RA_NOME
			cDtANas:=Substr(TRBF1402->RA_NASC		,3,2)//Ano de Nascimento
			cDtMNas:=Substr(TRBF1402->RA_NASC		,5,2)//Mes de Nascimento
			cDtDNas:=Substr(TRBF1402->RA_NASC		,7,2)//Dia de Nascimento
			cDtAAdm:=Substr(TRBF1402->RA_ADMISSA	,3,2)//Ano de Admissao
			cDtMAdm:=Substr(TRBF1402->RA_ADMISSA	,5,2)//Mes de Admissao
			cDtDAdm:=Substr(TRBF1402->RA_ADMISSA	,7,2)//Dia de Admissao
			nSalSem:=Transform((TRBF1402->RA_SALARIO/30)*7,"@E 999,999,999.99")
			cDomici:=Alltrim(TRBF1402->RA_ENDEREC)+Iif(!empty(TRBF1402->RA_COMPLEM),','+Alltrim(TRBF1402->RA_COMPLEM)," ")+Iif(!empty(TRBF1402->RA_BAIRRO),"-"+Alltrim(TRBF1402->RA_BAIRRO)," ")//Endereco
			lNacVen:=Iif(TRBF1402->RA_NACIONA=="60",.T.,.F.)		//Nacionalidade 
			cSitFol:=TRBF1402->RA_SITFOLH							//Situacao
			cCatFun:=TRBF1402->RA_CATFUNC							//Situacao
			cDepart:=Alltrim(TRBF1402->RA_DEPTO) 					//departamento
			cCargo :=TRBF1402->RA_CARGO								//Cargo
			cDCargo:=FDESC("SQ3",TRBF1402->RA_CARGO,"Q3_DESCSUM")	//Descricao do cargo
			lHabMot:=Iif(TRBF1402->RA_HABILMT=="1",.T.,.F.)			//Canhoto ou Destro
			cSexo  :=TRBF1402->RA_SEXO								//Sexo
			Do While TRBF1402->(!Eof()).And.TRBF1402->RA_MAT==cMatAss 
				AADD(aDepFun,{TRBF1402->RB_GRAUPAR,Alltrim(TRBF1402->RB_RG),TRBF1402->RB_SEXO,TRBF1402->RB_NOME,TRBF1402->RB_SECNOME,;
				TRBF1402->RB_DTNASC,TRBF1402->RB_MAT })		
				TRBF1402->(DbSkip()) 
			End                                                                                               
			If nAsseg>0
				oPrint:EndPage()	
				oPrint:StartPage()
				CabF142()
			Endif
			
			nAsseg++
			
			nLin-=40
			oPrint:Say(nLin,nCol  	  ,cNomEmp ,oArial10N)
			oPrint:Say(nLin,nCol+1380 ,Substr(cCgcEmp,1,1) ,oArial10N)
			oPrint:Say(nLin,nCol+1450 ,Substr(cCgcEmp,2,1) ,oArial10N)
			oPrint:Say(nLin,nCol+1520 ,Substr(cCgcEmp,3,1) ,oArial10N)
			oPrint:Say(nLin,nCol+1590 ,Substr(cCgcEmp,4,1) ,oArial10N)
			oPrint:Say(nLin,nCol+1650 ,Substr(cCgcEmp,5,1) ,oArial10N)
			oPrint:Say(nLin,nCol+1710 ,Substr(cCgcEmp,6,1) ,oArial10N)
			oPrint:Say(nLin,nCol+1780 ,Substr(cCgcEmp,7,1) ,oArial10N)
			oPrint:Say(nLin,nCol+1850 ,Substr(cCgcEmp,8,1) ,oArial10N)
			oPrint:Say(nLin,nCol+1910 ,Substr(cCgcEmp,9,1) ,oArial10N)																								
			
			nLin+=160         
			If lNacVen//Nacionalidade Venezuelana
				oPrint:Say(nLin,nCol     ,"1",oArial10N)
			Else
				oPrint:Say(nLin,nCol+70  ,"2",oArial10N)
			Endif
			oPrint:Say(nLin,nCol+150  ,cRGFun ,oArial10N)//Rg do Assegurado             
			If Len(cNAFun)<9
				cNAFun:=Strzero(0,9-len(cNAFun))+Alltrim(cNAFun)
			Endif
			oPrint:Say(nLin,nCol+1090 ,cNAFun ,oArial10N)//Numero de Assegurado			
			oPrint:Say(nLin,nCol+1580 ,cDepart,oArial10N)//Departameno  
			nLin+=200
			oPrint:Say(nLin,nCol   	  ,cNomFun,oArial10N)//Nome do Funcionario ou Assegurado                                  
			oPrint:Say(nLin,nCol+1240 ,cDtDNas,oArial10N)//Dia de Nascimento Assegurado		
			oPrint:Say(nLin,nCol+1380 ,cDtMNas,oArial10N)//Mes de Nascimento Assegurado	
			oPrint:Say(nLin,nCol+1540 ,cDtANas,oArial10N)//Ano de Nascimento Assegurado	 
			If cCatFun=="1"
				oPrint:Say(nLin-40,nCol+1880 ,"x",oArial10N)//Assegurado Pensionista
			ElseIf cCatFun=="2"	
				oPrint:Say(nLin+15,nCol+1880 ,"x",oArial10N)//Assegurado Aposentado
			Endif	
			
			nLin+=200                    
			If cSexo=="M"
				oPrint:Say(nLin,nCol   	  ,"X" ,oArial10N)
			Else
				oPrint:Say(nLin,nCol+80	  ,"X" ,oArial10N)
			Endif
			If lHabMot            
				oPrint:Say(nLin,nCol+150  ,"X" ,oArial10N)
				oPrint:Say(nLin,nCol+360  ,"1" ,oArial10N)              
			Else                                          
				oPrint:Say(nLin,nCol+230  ,"X" ,oArial10N)
				oPrint:Say(nLin,nCol+360  ,"2" ,oArial10N)              			
			Endif	
			oPrint:Say(nLin,nCol+480  ,cDtDAdm,oArial10N)//Dia da Admissao do Assegurado						
			oPrint:Say(nLin,nCol+620  ,cDtMAdm,oArial10N)//Mes da Admissao do Assegurado			
			oPrint:Say(nLin,nCol+760  ,cDtAAdm,oArial10N)//Ano da Admissao do Assegurado
			oPrint:Say(nLin,nCol+920  ,nSalSem,oArial10N)//Salario Semanal
			oPrint:Say(nLin,nCol+1240 ,cDCargo ,oArial10N)//Descricao do cargo			
			oPrint:Say(nLin,nCol+1800 ,cCargo ,oArial10N)//Cargo			
			nLin+=180   
			oPrint:Say(nLin,nCol   	  ,cDomici ,oArial10N)			
			nLin+=230                             
			For nDep:=1 To Len(aDepFun)
				IF	nDep <= 6 
					If !Empty(aDepFun[nDep][7])
						oPrint:Say(nLin,nCol   	  ,Substr(aDepFun[nDep][1],1,10) ,oArial10N)//Grau de Parentesco do Dependente
						oPrint:Say(nLin,nCol+250  ,aDepFun[nDep][2] ,oArial10N)//RG do Dependente 
						If aDepFun[nDep][3]=="M"
							oPrint:Say(nLin,nCol+670  ,'X' ,oArial10N)//Sexo do Dependente               
						ElseIf aDepFun[nDep][3]=="F"                                                                                                                        
							oPrint:Say(nLin,nCol+740  ,'X' ,oArial10N)//Sexo do Dependente               
						Endif
						oPrint:Say(nLin,nCol+800  ,Iif(!Empty(aDepFun[nDep][4]),aDepFun[nDep][4],"-") ,oArial10N)//Nome do Dependente               
						oPrint:Say(nLin,nCol+1650 ,Substr(aDepFun[nDep][6],7,2),oArial10N)//Dia Nasc. do Dependente               
						oPrint:Say(nLin,nCol+1770 ,Substr(aDepFun[nDep][6],5,2),oArial10N)//Mes Nasc. do Dependente               
						oPrint:Say(nLin,nCol+1880 ,Substr(aDepFun[nDep][6],3,2),oArial10N)//Ano Nasc. do Dependente               				
						nLin+=085
					Endif
				ENDIF
			Next
		End	    
		aDepFun:={}
		cMatAss:=TRBF1402->RA_MAT
	End
	oPrint:EndPage()	
	If aReturn[5]==1
		MsgRun(STR0007,STR0003, {||CursorWait(),oPrint:Preview(),CursorArrow()})//Carregando Layout#Aguarde...  				
	Endif
Else
    Aviso(STR0009,STR0008 ,{ "OK" } )//"Atencao"#"Nao ha informacoes para serem geradas.Verifique os parametros"		
Endif

Return           

/*
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北
北谀哪哪哪哪履哪哪哪哪履哪哪哪履哪哪哪哪哪哪哪哪哪哪哪哪穆哪哪哪履哪哪哪哪目北
北矲uncao   � CabF142  � Autor 矼arcos Kato              � Data � 28/11/08 潮�
北媚哪哪哪哪拍哪哪哪哪聊哪哪哪聊哪哪哪哪哪哪哪哪哪哪哪哪牧哪哪哪聊哪哪哪哪拇北
北矰escricao� Cabecalho do relatorio assegurado   					       潮�
北媚哪哪哪哪拍哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪拇北
北� Uso     � Microsiga						                               潮�
北滥哪哪哪哪聊哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪馁北
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北
*/

Static Function CabF142
oPrint:Saybitmap(200,200,cStartPath+"F1402"+".jpg",2000,3000)  
nCol:=220
nLin:=650
If nTipRel==1
	oPrint:Say(nLin,nCol+440  ,"X",oArial10N)
	nLin+=150
ElseIf nTipRel==2
	oPrint:Say(nLin+70,nCol+930  ,"X",oArial10N)
	nLin+=150        
ElseIf nTipRel==3	
	oPrint:Say(nLin+70,nCol+1440 ,"X",oArial10N)
	nLin+=150        
ElseIf nTipRel==4	
	oPrint:Say(nLin+70,nCol+1910 ,"X",oArial10N)
	nLin+=150        
Else
	nLin+=70        
Endif	
nLin+=130
Return