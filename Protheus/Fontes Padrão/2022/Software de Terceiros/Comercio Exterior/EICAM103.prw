#INCLUDE "RWMAKE.CH" 
#INCLUDE "AVERAGE.CH"
#INCLUDE "TOPCONN.CH"
#INCLUDE "EICAM103.CH" 

/*##########################################################
#                 ___  "  ___                              #
#               ( ___ \|/ ___ ) Kazoolo                    #
#                ( __ /|\ __ )  Codefacttory               #
############################################################
#  Função :    # EICAM103                                  # 
############################################################
# Retorno :    # NIL                                       #
############################################################
# Descrição :  # CHAMADA PARA CRIAÇÃO DA GETDADOS          #
############################################################
# Autor :      # Cleber Cintra Barbosa                     #
############################################################
# Data :       #  12/05/10                                 #
############################################################
# Palavras Chaves :  #                                     #
##########################################################*/ 

Function EICAM103()
	
	Local alGetDados := {"AllwaysTrue" , "AllwaysTrue" ,"+EWH_LINHA",,,,,/*"AllwaysTrue"*//*"ValidaQtd('EWH_QTD')"*/"ValidaGetDados()" ,,}
    Local alMemo     := {}
	Local alCampos	 := {}
	Local alRelac	 := {}
	
	aAdd(alRelac,{"EWG_HAWB","EWH_HAWB"})
	aAdd(alRelac,{"EWG_CODPAR","EWH_CODPAR"})

    AM103_Mod3("EWG",1,"EWH",1,alRelac,alCampos , alGetDados, /*aButton*/, alMemo)                                       	
	
Return Nil 

/*##########################################################
#                 ___  "  ___                              #
#               ( ___ \|/ ___ ) Kazoolo                    #
#                ( __ /|\ __ )  Codefacttory               #
############################################################
#  Função :    # AM103_Mod3                                  # 
############################################################
# Parametros : # clTab1 :TABELA DE CABEÇALHO               #
#              # nl1Ord :INDICE 				           #   
#              # clTab2 :TABELA DE ITENS                   #
#              # nl2Ord :INDICE                            #
#              # alRelacGrv :CAMPOS QUE POSSUEM DO CABEÇALHO QUE POSSUEM RELAÇÃO COM OS ITENS
#              # alEnchoice : ARRAY COM OS CAMPOS PARA MONTAGEM DA ENCHOICE  #
#              # alGetDados :                              #
#              # alBtnsBar : BOTOES ADICIONAIS DO ENCHOICEBAR                              #
#              # alMemo : ARRAY COM OS CAMPOS MEMO              #
############################################################
# Retorno :    # NIL                                       #
############################################################
# Descrição :  # MONSTAGEM DA TELA COM ENCJOICE E GETDADOS #
############################################################
# Autor :      # Cleber Cintra Barbosa                     #
############################################################
# Data :       #  12/05/10                                 #
############################################################*/                                                                                                      

Function AM103_Mod3(clTab1,nl1Ord,clTab2,nl2Ord,alRelacGrv,alEnchoice,alGetDados,alBtnsBar,alMemo)
	Local nlCont        := 0              
	Local alBtRot       := {}                     
	Local clRetGet      := FGetTitleAlia(clTab1)               
	Private aKzM3Info   := {{clTab1,nl1Ord},{clTab2,nl2Ord}} 
	Private aKzM3Ench   := aClone(alEnchoice)
	Private aKzM3GetD   := aClone(alGetDados)     
	Private aKzM3Btns   := aClone(alBtnsBar)    
	Private aKzM3GrvR   := aClone(alRelacGrv)         
	Private aKzM3Memo   := aClone(alMemo)
	Private aKzM3Visu   := {}
	Private cDelFunc 	:= ".T." 
	Private cCadastro 	:= STR0001
	Private aRotina 	:= { 	{STR0002 	,"AxPesqui"	    ,0,1} ,;
	             				{STR0003 	,"AM103MOD103"	,0,2} ,;
	             				{STR0004 	,"AM103MOD103"	,0,3} ,;
	           					{STR0005 	,"AM103MOD103"	,0,4} ,;
	             				{STR0006 	,"AM103MOD103"	,0,5} }
	Private aDeletados := {}
                         
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Adicionar botoes no aRotina       ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ                          
	For nlCont:=1 to Len(alBtRot)
		aAdd(aRotina,alBtRot[nlCont])
	Next nlCont      
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Monta mBrowse padrao Protheus     ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ 
	dbSelectArea(clTab1)
	dbSetOrder(nl1Ord)
	mBrowse( 6,1,22,75,clTab1)
	
Return Nil    

/*##########################################################
#                 ___  "  ___                              #
#               ( ___ \|/ ___ ) Kazoolo                    #
#                ( __ /|\ __ )  Codefacttory               #
############################################################
#  Função :    # AM103Mod103                               # 
############################################################
# Parametros : # cAlias : Alias da tabela do browse        #
#              # nReg   : Recno do Registro na tabela      #   
#              # nOpc   : Opcao selecionada pelo usuario   #
############################################################
# Retorno :    # NIL                                       #
############################################################
# Descrição :  # Funcao responsavel pela estrutura da      #
#              # rotina. Nela e' criado tela, montagem do  #
#              # aHeader, aCols e etc...                   #
############################################################
# Autor :      # Demetrio Fontes De Los Rios               #
############################################################
# Data :       #  02/02/10                                 #
############################################################
# Palavras Chaves :  # Monta Modelo 3-Tela/aHeader/aCols   #
##########################################################*/
Function AM103Mod103(cAlias,nReg,nOpc)  
	Local alMSSize  := MsAdvSize(,.F.,430)  
	Local clTitle   := cCadastro                //  Titulo da Tela
	Local nlDlgHgt 	:= 0                        //  Tamanho Tela
	Local nlGDHgt   := 0						//  Tamanho GetDados                    
	Local alCorTel  := {alMSSize[7],0,alMSSize[6],alMSSize[5]}			    //  Coordenadas da Tela
	Local nlSizeHd  := 350                      //  Tamanho cabecalho
	Local olDlg		:= NIL						//   Dialog Principal   
//	Local olEnch    := NIL                      //  Objeto Enchoice
	Local clAwTrue  := "AllwaysTrue()"          //  Funcao AllwaysTrue 
	Local cl1Alias  := aKzM3Info[1,1]           //  Alias Tabela 1 - Cabecalho
	Local cl2Alias  := aKzM3Info[2,1]           //  Alias Tabela 2 - Itens 
	Local nlOr2     := aKzM3Info[2,2]		 	 //  Order do Alias 2        
                   
	// Enchoice
	Local alAltEnch := Iif(  (Type("aKzM3Ench[1]")<>"A") ,NIL      , aKzM3Ench[01] )  // Campos Alteraveis
	Local nlModEnch := Iif(  (Type("aKzM3Ench[2]")<>"N") ,1        , aKzM3Ench[02] )  // Model   
	Local clENTdOk  := Iif(  (Type("aKzM3Ench[3]")<>"C") ,clAwTrue , aKzM3Ench[03] )  // Tudo Ok - Enchoice
	Local llVerObg  := Iif(  (Type("aKzM3Ench[4]")<>"L") ,.T.      , aKzM3Ench[04] )  // Verificar campos obrigatorios       
	Local llColumn  := Iif(  (Type("aKzM3Ench[5]")<>"L") ,.F.      , aKzM3Ench[05] )  // Tudo em Coluna          
	Local llObgOk   := .F.  
	Local alEncVirt := {}

	// GetDados
	Local clLinOk   := Iif( (Type("aKzM3GetD[01]")<>"C"), clAwTrue ,  aKzM3GetD[01]  ) // Linha Ok - Get Dados 
	Local clTdOk    := Iif( (Type("aKzM3GetD[02]")<>"C"), clAwTrue ,  aKzM3GetD[02]  ) // Tudo Ok - Get Dados
	Local clCpoIni  := Iif( (Type("aKzM3GetD[03]")<>"C"), NIL      ,  aKzM3GetD[03]  ) // Que utilizarao incremento automtico     
	Local llDelGd   := .T. //Iif( (Type("aKzM3GetD[04]")<>"L"), .F.      ,  aKzM3GetD[04]  ) // Habilita excluir linhas - Default .T.
	Local aAltGd    := Iif( (Type("aKzM3GetD[05]")<>"A"), NIL      ,  aKzM3GetD[05]  ) // Array com os campos Alteraveis
	Local llEmptyGd := Iif( (Type("aKzM3GetD[06]")<>"L"), .F.      ,  aKzM3GetD[06]  ) // Validacao primeira coluna nao ser vazia = Default .F.     
	Local nlMaxLLin := Iif( (Type("aKzM3GetD[07]")<>"N"), 999      ,  aKzM3GetD[07]  ) // Numero maximo de linhas acols = Default 99  
	Local clFilOkGd := Iif( (Type("aKzM3GetD[08]")<>"C"), NIL	   ,  aKzM3GetD[08]  ) // Validacao do campo    
	Local clSDelGd  := Iif( (Type("aKzM3GetD[09]")<>"C"), NIL      ,  aKzM3GetD[09]  ) // Super Del                
	Local clDelOkGd := Iif( (Type("aKzM3GetD[10]")<>"C"),          ,  aKzM3GetD[10]  ) // Funcao Executada na exclusao da linha
	
	// Enchoice Bar       
	Local llDelBar  := Iif((nOpc==5),.T.,.F.)
	Local alBtEnBar := {}
	
	Local alSize    := {} 
	Local nlCont    := 0 
	Local alCpoEnch := {}       
	Local aTitulos  := {}
 
	// Variaveis aHeader
	Local nlUsado   	:= 0 					 // Numero de Campos em uso 
	Local alHVtCpo  	:= {}                   // Array com os campos virtuais
	Local alHVsCpo  	:= {}                   // Array com os campos visuais  
	Local alNotCpH  	:= {}  	 // Campos que nao deverao constar no aHeader  
	
	// Variaveis aCols 
	Local alHdGd 		:= {} 
	Local alRecGd   	:= {}

	Private VISUAL  	:= Iif((nOpc==2),.T.,.F.)                       
	Private INCLUI  	:= Iif((nOpc==3),.T.,.F.)                         
	Private ALTERA  	:= Iif((nOpc==4),.T.,.F.)                         
	Private DELETA  	:= Iif((nOpc==5),.T.,.F.) 
	Private lRefresh	:= .T.
	Private aTELA		:= Array(0,0)
	Private aGets		:= Array(0)    
	Private aHeader	 	:= {}
	Private aCols  		:= {}
	Private opGetDd   	:= NIL                      //  Objeto GetDados       
	Private dpDt_Ven	:= CToD("")
	Private npVlr_R		:= 0
	Private cpHAWB		:= ""
	Private cpDespes	:= ""
	Private olEnch    := NIL                      //  Objeto Enchoice                     
		
  	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Monta aHeader       ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ 	
   	aHeader := GdMontaHeader(  		@nlUsado     	,; //01 -> Por Referencia contera o numero de campos em Uso
  									@alHVtCpo       ,; //02 -> Por Referencia contera os Campos do Cabecalho da GetDados que sao Virtuais
  									@alHVsCpo       ,; //03 -> Por Referencia contera os Campos do Cabecalho da GetDados que sao Visuais
  									cl2aLias        ,; //04 -> Opcional, Alias do Arquivo Para Montagem do aHeader
  									alNotCpH		,; //05 -> Opcional, Campos que nao Deverao constar no aHeader
  									.F.             ,; //06 -> Opcional, Carregar Todos os Campos
  									.F.             ,; //07 -> Nao Carrega os Campos Virtuais
  									.F.             ,; //08 -> Carregar Coluna Fantasma e/ou BitMap ( Logico ou Array )
  									NIL             ,; //09 -> Inverte a Condicao de aNotFields carregando apenas os campos ai definidos
  									.T.             ,; //10 -> Verifica se Deve Checar se o campo eh usado  
  									.T.             ,;
  									.F.             ,;
  									.F.             ,)               							
  	
  	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Monta aCols         ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ 
  	If INCLUI //.OR. (FQAcols(cl1aLias,cl2aLias) .And. EWGF->(EOF()))
  		aAdd(aCols,Array(nlUsado+1))    
  		For nlCont:=1 to nlUsado  
  			If !("_REC_WT"$aHeader[nlCont,2]) .AND. !("_ALI_WT"$aHeader[nlCont,2])    
	  			aCols[Len(aCols),nlCont]:=CriaVar(aHeader[nlCont,2])
  			EndIf
  		Next nlCont                                                   
  		aCols[(Len(aCols)),(nlUsado+1)] := .F.   
  	Else                                      

  		If FQAcols(cl1aLias,cl2aLias,nOpc) 
	  	   	While EWGH->(!EOF())
	  	   		dbSelectArea("EWH")
	  	   		dbGoTo(EWGH->EWH_RECNO)
				aADD(aCols,Array(nlUsado + 1))
				For nlCont := 1 to len(aHeader)  
					If "_REC_WT"$aHeader[nlCont,2]
						aCols[Len(aCols),nlCont] := EWGH->EWH_RECNO
					ElseIf "_ALI_WT"$aHeader[nlCont,2]
						aCols[Len(aCols),nlCont] := cl2aLias  
					Else
						aCols[Len(aCols),nlCont] := FieldGet(FieldPos(aHeader[nlCont][2]))      
					EndIf
					aCols[Len(aCols),len(aHeader)+1] := .F. //Linha deletada (nao deletada - .f.)
					
					If "EWH_DESSRV"$aHeader[nlCont,2]
						aCols[Len(aCols),nlCont] := Posicione("EWD",1,xFilial("EWD")+aCols[Len(aCols),aScan(aHeader,{|x| Alltrim(x[2]) == "EWH_CODSRV" })],"EWD_DESSRV") 
					EndIf
					
					If "EWH_DESPRC"$aHeader[nlCont,2]
						aCols[Len(aCols),nlCont] := Posicione("EW8",1,XFILIAL("EW8")+EWH->EWH_CODPRC,"EW8_DESPRC")
					EndIf
					
				Next nlCont		
	  	   		dbSelectArea("EWGH")
				EWGH->(DbSkip())
			EndDo     
			EWGH->(dbCloseArea())
		EndIf
  	EndIf
  	

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿             
	//³ CAMPOS USADOS PARA ENCHOICE   ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ 
    dbSelectArea("SX3")                                          
    SX3->(dbSetOrder(1))
    SX3->(dbGoTop())
	SX3->(dbSeek(cl1Alias))
	alCpoEnch:={}
	Do While !Eof().And.(SX3->X3_ARQUIVO==cl1Alias)     
		If X3USO(SX3->X3_USADO).And.cNivel>=SX3->X3_NIVEL
			Aadd(alCpoEnch, ALLTRIM(X3_CAMPO)   )
			Aadd(aTitulos , ALLTRIM(X3TITULO()) )   
			If SX3->X3_CONTEXTT=="V" 	// Verifica se o campo e' VIRTUAL 
				aAdd( alEncVirt , {ALLTRIM(X3_CAMPO), ALLTRIM(X3_TIPO)}  ) 
			EndIf
		Endif
		SX3->(DbSkip())
	End Do 
	
	If nOpc == 3					
		aCols[1][gdFieldPos("EWH_LINHA")]:= "001" 
	EndIf
		 
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ *************************************************************** ³
	//³  I N T E R F A C E                                              ³   
	//³ *************************************************************** ³      
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ 
	DEFINE MSDIALOG olDlg TITLE clTitle FROM alCorTel[1],alCorTel[2] TO alCorTel[3],alCorTel[4] PIXEL of oMainWnd 

        //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Enchoice                 ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ	       
		dbSelectArea(cl1Alias)    
        RegToMemory(cl1Alias,INCLUI,.T.,.T.) 
        
        If nOpc <> 3
	  		dpDt_Ven	:= M->EWG_DT_VEN
			npVlr_R		:= M->EWG_VL_TOT
			cpHAWB		:= M->EWG_HAWB
			cpDespes	:= M->EWG_DESPES
			
			For nlCont := 1 To FCount()
				M->&(FieldName(nlCont)) := &("EWG->"+(FieldName(nlCont)))
			Next nlCont
			
	    EndIf
		olEnch 	:= Msmget():New(cl1Alias,nReg ,nOpc ,     ,      ,       ,alCpoEnch ,{15,1,70,315} ,alAltEnch    ,nlModEnch ,         ,          ,clENTdOk ,olDlg  ,   ,        , llColumn       ,       ,          ,  ,,,,.T.)    
			//     MsMGet():New (cAlias  ,nReg ,nOpc ,aCRA ,cLetra ,cTexto ,aAcho     ,aPos           ,aCpos        ,nModelo   ,nColMens ,cMensagem ,cTudoOk  ,oWnd   ,lF3 ,lMemoria, lColumn, caTela, lNoFolder, lProperty)

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Get Dados                ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		opGetDd := MsGetDados():New( 45    ,1    ,nlGDHgt ,315    ,nOpc ,clLinOk   ,clTdOk   ,clCpoIni ,llDelGd ,aAltGd ,      ,llEmptyGd ,nlMaxLLin   ,/*clSDelGd*//*"ValidaGetDados"*/clFilOkGd ,          ,clDelOkGd      ,       ,    )        
//				   MsGetDados():New (nTop ,nLeft ,nBottom ,nRight ,nOpc ,cLinhaOk  ,cTudoOk  ,cIniCpos ,lDelete ,aAlter ,uPar1 ,lEmpty    ,nMax        ,cFieldOk ,cSuperDel ,uPar2          ,cDelOk ,oWnd)         

	ACTIVATE MSDIALOG olDlg ON INIT (EnchoiceBar(olDlg, {|| Iif((!VISUAL),( (llObgOk:=Iif(llVerObg,Obrigatorio(aGets,aTela,aTitulos),!llVerObg)) , ;
	 (Iif(llObgOk,(IIf(AM103VLD(nOpc),(ConfirmSx8(),Close(olDlg)),NIL)),/*Obrig. .F.*/)), ),Close(olDlg))  },; // Botao Ok
														{|| llObgOk:=.F.,Close(olDlg), RollBackSx8()      },; 
														llDelBar,;
														alBtEnBar),AlignObject(olDlg,{olEnch:oBox,opGetDd:oBrowse},1,,alSize)) VALID AM103TOK(nOpc)
	
	If llObgOk
		Begin Transaction
		  	FExe(cl1Alias, cl2Alias, nlUsado, nReg, alCpoEnch, alEncVirt, nlOr2)
			dbSelectArea("EWG")
 			EWG->(dbSetOrder())
	 		EWG->(dbGoTop())
 			dbSeek(xFilial("EWG") + M->EWG_HAWB + M->EWG_CODPAR)

		  	If !FGrava(nOpc)
		  		DisarmTransaction()
		  	Endif
 		End Transaction
	EndIf
	
Return Nil                                                                                                                                 
   
/*##########################################################
#                 ___  "  ___                              #
#               ( ___ \|/ ___ ) Kazoolo                    #
#                ( __ /|\ __ )  Codefacttory               #
############################################################
#  Função :    # FQAcols                                   # 
############################################################
# Parametros : # clCabcAlias : Alias do cabecalho          #
#              # clItnsAlias : Alias dos itens             #   
############################################################
# Retorno :    # .T.                                       #
############################################################
# Descrição :  # Funcao responsavel pela query de selecao  #
#              # dos itens da tela                         #
############################################################
# Autor :      # Demetrio Fontes De Los Rios               #
############################################################
# Data :       #  02/02/10                                 #
############################################################
# Palavras Chaves :  # Monta Query                         #
##########################################################*/
Static Function FQAcols(clCabcAlias, clItnsAlias,nlOpc,nlOpcD) 
    
	Local clQuery 	:= ""     
	Local nlI     	:= 0
	Local nRegCol   := 0
	
	If Select("EWGF") > 0
		EWGF->(dbCloseArea())
	EndIf
    
	If Select("EWGH") > 0
	   EWGH->(dbCloseArea())
	EndIf
    
    If nlOpc == 3 //INCLUI
		clQuery := "SELECT EW8_FORMUL,EWD_CDTINI,EWD_CDTFIM,EWD_CDTPRV,EW8_DESPRC,EWD_DESSRV,EWF_CODARM,EWF_CODSRV,EWF_PRCUNI,EWF_CODTAB,EWF_PERIOD,EWF_ALISS,EWF_PRCTOT,EWF_OBS,EWF_CODPRC "
		clQuery += "FROM " + RetSqlName("EWF") + " EWF "
		clQuery += "INNER JOIN " + RetSqlName("EWD") + " EWD "
		clQuery += "ON EWF_CODSRV = EWD_CODSRV "
		clQuery += "AND EWD.D_E_L_E_T_ = ' '  "
		clQuery += "INNER JOIN " + RetSqlName("EW8") + " EW8 "
		clQuery += "ON EWF_CODPRC = EW8_CODPRC "
		clQuery += "AND EW8.D_E_L_E_T_ = ' ' "
		clQuery += "WHERE EWF_CODTAB = '" + Iif(nlOpc==3,ALLTRIM(M->EWG_CODTAB),ALLTRIM(EWG->EWG_CODTAB)) + "'" 
		clQuery += "AND EWF.D_E_L_E_T_ = ' ' AND EW8.EW8_FILIAL='"+xFilial("EW8")+"'"//FDR - 24/05/11
		clQuery += "AND EWD.EWD_FILIAL='"+xFilial("EWD")+"'"
		clQuery += "AND EWF.EWF_FILIAL='"+xFilial("EWF")+"'"		
		clQuery += "ORDER BY EWF_CODSRV"
				
		TcQuery clQuery new Alias "EWGF"
		 
		DbSelectArea("EWGF")
		EWGF->(dbGoTop())
		nRegCol := 0
		Do While !eof()
			nRegCol ++
			if nRegCol > Len(aCols)
				aAdd(aCols,aClone(aCols[nRegCol-1]))
				aCols[nRegCol][Ascan(aHeader,{|x|"_REC_WT"$Alltrim(X[2])})] := 0
			Endif
			dbSkip()
		Enddo
		EWGF->(dbGoTop())
		If EWGF->(!EOF())
			M->EWG_VL_TOT := 0
			M->EWG_VL_PRV := 0
			For nLI := 1 to len(aCols)
				aCols[nLI][gdFieldPos("EWH_LINHA")] := StrZero(nLI,TamSx3("EWH_LINHA")[1])
				aCols[nLI][gdFieldPos("EWH_CODSRV")] := EWF_CODSRV
				aCols[nLI][gdFieldPos("EWH_DESSRV")] := EWD_DESSRV
				aCols[nLI][gdFieldPos("EWH_PERIOD")] := iif(EWF_PERIOD>0,EWF_PERIOD,1)
				aCols[nLI][gdFieldPos("EWH_DT_INI")] := iif(!Empty(EWD_CDTINI),Am103Exec("EWD_CDTINI",ctod("//")),ctod("//"))
				aCols[nLI][gdFieldPos("EWH_DT_FIM")] := iif(!Empty(EWD_CDTFIM),Am103Exec("EWD_CDTFIM",ctod("//")),ctod("//"))
				aCols[nLI][gdFieldPos("EWH_DIAS")]	 := IIF((aCols[nLI][gdFieldPos("EWH_DT_FIM")]-aCols[nLI][gdFieldPos("EWH_DT_INI")]+1)<1,1,(aCols[nLI][gdFieldPos("EWH_DT_FIM")]-aCols[nLI][gdFieldPos("EWH_DT_INI")]+1))
				aCols[nLI][gdFieldPos("EWH_QTDPER")] := IIF(INT(ACOLS[NLI][gdFieldPos("EWH_DIAS")]/aCols[nLi][gdFieldPos("EWH_PERIOD")])+IF(aCols[NLI][gdFieldPos("EWH_DIAS")]%ACOLS[NLI][gdFieldPos("EWH_PERIOD")]>0,1,0)<1,1,INT(ACOLS[NLI][gdFieldPos("EWH_DIAS")]/aCols[nLi][gdFieldPos("EWH_PERIOD")])+IF(aCols[NLI][gdFieldPos("EWH_DIAS")]%ACOLS[NLI][gdFieldPos("EWH_PERIOD")]>0,1,0))
				//aCols[nLI][gdFieldPos("EWH_CODPRC")] := EWF_CODPRC
				aCols[nLI][gdFieldPos("EWH_DESPRC")] := EW8_DESPRC
				aCols[nLI][gdFieldPos("EWH_QTD")]	 := iif(!Empty(EW8_FORMUL),Am103Exec("EW8_FORMUL",0),0)
				aCols[nLI][gdFieldPos("EWH_PRCUNI")] := EWF_PRCUNI		
				aCols[nLI][gdFieldPos("EWH_ALISS")]  := EWF_ALISS
				aCols[nLI][gdFieldPos("EWH_PRCTOT")] := EWF_PRCTOT
				If (!Empty(M->EWG_DT_INI) .And. !Empty(M->EWG_DT_FIM)) .Or. aCols[nLI][gdFieldPos("EWH_QTDPER")] > 0
   			   	   aCols[nLI][gdFieldPos("EWH_VL_TOT")] := Round(aCols[nLI][gdFieldPos("EWH_PRCTOT")]*aCols[nLI][gdFieldPos("EWH_QTD")]*aCols[nLI][gdFieldPos("EWH_QTDPER")],AvSX3("EWH_VL_TOT",AV_DECIMAL))
   				   M->EWG_VL_TOT += aCols[nLI][gdFieldPos("EWH_VL_TOT")] 
                EndIf
				aCols[nLI][gdFieldPos("EWH_OBS")]	 := EWF->EWF_OBS
				aCols[nLI][gdFieldPos("EWH_PRVFIM")] := iif(!Empty(EWD_CDTPRV),Am103Exec("EWD_CDTPRV",ctod("//")),ctod("//"))
				If !Empty(M->EWG_DT_INI) .And. !Empty(M->EWG_PRVFIM)
				   aCols[nLI][gdFieldPos("EWH_VL_PRV")] := IIF(aCols[nLI][gdFieldPos("EWH_PRCTOT")]*aCols[nLI][gdFieldPos("EWH_QTD")]*(INT((aCols[nLI][gdFieldPos("EWH_PRVFIM")]-aCols[nLI][gdFieldPos("EWH_DT_INI")]+1)/aCols[nLI][gdFieldPos("EWH_PERIOD")])+iF((aCols[nLI][gdFieldPos("EWH_PRVFIM")]-aCols[nLI][gdFieldPos("EWH_DT_INI")]+1)%aCols[nLI][gdFieldPos("EWH_PERIOD")]>0,1,0))<0,0,aCols[nLI][gdFieldPos("EWH_PRCTOT")]*aCols[nLI][gdFieldPos("EWH_QTD")]*(INT((aCols[nLI][gdFieldPos("EWH_PRVFIM")]-aCols[nLI][gdFieldPos("EWH_DT_INI")]+1)/aCols[nLI][gdFieldPos("EWH_PERIOD")])+iF((aCols[nLI][gdFieldPos("EWH_PRVFIM")]-aCols[nLI][gdFieldPos("EWH_DT_INI")]+1)%aCols[nLI][gdFieldPos("EWH_PERIOD")]>0,1,0))) 
				   M->EWG_VL_PRV += aCols[nLI][gdFieldPos("EWH_VL_PRV")]
				EndIf

				EWGF->(DbSkip())
			Next nLI
		EndIf
		For nLI := nRegCol+1 To Len(aCols)
		    If aCols[nLi][Ascan(aHeader,{|x|"_REC_WT"$Alltrim(X[2])})] > 0
   	           aAdd(aDeletados, aCols[nLi][Ascan(aHeader,{|x|"_REC_WT"$Alltrim(X[2])})])
   	        EndIf
	        aDel(aCols, nLi)
	        aSize(aCols, Len(aCols)-1)
	        //aCols[nLI][Len(aCols[nLi])] := .T.
        Next

		
	Else
		clQuery := " SELECT R_E_C_N_O_ AS EWH_RECNO"
		clQuery += " FROM " + RetSqlName("EWH") + " EWH "
		clQuery += " WHERE EWH.D_E_L_E_T_ = ' ' "
		clQuery += " AND EWH_FILIAL = '"+EWG->EWG_FILIAL+"'"
		clQuery += " AND EWH_HAWB = '"+EWG->EWG_HAWB+"'"
		clQuery += " AND EWH_CODPAR = '"+EWG->EWG_CODPAR+"'"
		
		TcQuery clQuery new Alias "EWGH"
	    dbSelectArea("EWGH")
    	EWGH->(dbGoTop())
		
	Endif
			
	If nlOpc == 3
		opGetDd:Refresh()
		//If Select("EWGF") > 0
		  // EWGF->(DbCloseArea())
		//EndIf
	EndIf 
		    
Return .T.   

/*##########################################################
#                 ___  "  ___                              #
#               ( ___ \|/ ___ ) Kazoolo                    #
#                ( __ /|\ __ )  Codefacttory               #
############################################################
#  Função :    # FExe                                      # 
############################################################
# Parametros : # cl1Tab    : Alias do cabecalho            #
#              # cl2Tab    : Recno do Registro na tabela   #   
#              # nlUsado   : Opcao selecionada pelo usuario#
#              # nlReg     : Recno do Registro na tabela   #   
#              # alCpoEnch : Opcao selecionada pelo usuar  #
#              # alVirtual : Recno do Registro na tabela   #   
#              # nlOrder   : Opcao selecionada pelo usuario#
############################################################
# Retorno :    # NIL                                       #
############################################################
# Descrição :  # Funcao principal executada na confirmacao #
#              # da tela. Nela e' chamada a rotina correta #
#              # conforme a escolha do usuario             #
############################################################
# Autor :      # Demetrio Fontes De Los Rios               #
############################################################
# Data :       #  02/02/10                                 #
############################################################
# Palavras Chaves :  # Monta Modelo 3-Tela/aHeader/aCols   #
##########################################################*/
Static Function FExe(cl1Tab, cl2Tab, nlUsado, nlReg, alCpoEnch, alVirtual, nlOrder)
	If !INCLUI  
		If !ALTERA 
			FDelKzM(cl1Tab,cl2Tab, nlReg)  				
		Else
			FAltKzM(cl1Tab,cl2Tab, nlReg, alCpoEnch, alVirtual, nlUsado)
		EndIf
	Else
		FGrvKzM(cl1Tab,cl2Tab, alCpoEnch, alVirtual, nlUsado, nlOrder)
	EndIf
Return Nil     


/*##########################################################
#                 ___  "  ___                              #
#               ( ___ \|/ ___ ) Kazoolo                    #
#                ( __ /|\ __ )  Codefacttory               #
############################################################
#  Função :    # FGrvKzM3                                 # 
############################################################
# Parametros : # cAlias : Alias da tabela do browse        #
#              # nReg   : Recno do Registro na tabela      #   
#              # nOpc   : Opcao selecionada pelo usuario   #
############################################################
# Retorno :    # NIL                                       #                                	
############################################################
# Descrição :  # Funcao responsavel pela estrutura da      #
#              # rotina. Nela e' criado tela, montagem do  #
#              # aHeader, aCols e etc...                   #
############################################################
# Autor :      # Demetrio Fontes De Los Rios               #
############################################################
# Data :       #  02/02/10                                 #
############################################################
# Palavras Chaves :  # Monta Modelo 3-Tela/aHeader/aCols   #
##########################################################*/
Static Function FGrvKzM(cl1Tab,cl2Tab, alCpoEnch, alVirtual, nlUsado )       
	Local nlG		:= 0  
	Local nlI       := 0             
	Local nlCont    := 0                 
	Local c11Fil    := FSelCpoFi(cl1Tab)     
	Local cl2Fil    := FSelCpoFi(cl2Tab)    
	Local clFilial  := xFilial(cl1Tab)       


	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Grava  Cabecalho         ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ     
	dbSelectArea(cl1Tab)   
	If RecLock(cl1Tab,INCLUI)  
		Replace &(cl1Tab+"->"+c11Fil) With clFilial                                                                             
		For nlG:=1 to Len(alCpoEnch)    
			If (  aScan(alVirtual,{|x|Alltrim(X[1])==AllTrim(alCpoEnch[nlG])})==0) 
				cl1Var := cl1Tab+"->"+alCpoEnch[nlG] 
				cl2Var := "M->"+alCpoEnch[nlG]
				Replace &cl1Var With &cl2Var	
			EndIf 
	    Next nlG  
		&(cl1Tab)->(MsUnlock())
	EndIf                                        
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Grava  Itens             ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ     
 	dbSelectArea(cl2Tab)        
	For nlI:=1 to Len(aCols)
		If !aCols[nlI,nlUsado+1] 
			If RecLock(cl2Tab,INCLUI) 
			    Replace &(cl2Tab+"->"+cl2Fil) With clFilial
			    Replace EWH->EWH_CODPAR WITH EWG->EWG_CODPAR
			  	For nlG:=1 to Len(aHeader)  
			  		If aHeader[nlG,10] <> "V"
			  			FieldPut(FieldPos(aHeader[nlG][2]),aCols[nlI][nlG])	 
			  		EndIf
			  	Next nlG	                                 
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
   				//³ Grava  Relacionamento    ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ    
				For nlCont:=1 to Len(aKzM3GrvR) 
					Replace &(aKzM3GrvR[nlCont,2]) With &(aKzM3GrvR[nlCont,1])			
				Next nlCont 
				// Grava outros campos
			    Replace EWH->EWH_CDTINI WITH Posicione("EWD",1,xFilial("EWD") + EWH->EWH_CODSRV,"EWD_CDTINI")
			    Replace EWH->EWH_CDTFIM WITH EWD->EWD_CDTFIM
			    Replace EWH->EWH_CDTPRV WITH EWD->EWD_CDTPRV
			    Replace EWH->EWH_CODPRC WITH EWD->EWD_CODPRC
		    	&(cl2Tab)->(MsUnLock()) 	 
			EndIf    
		EndIf
	Next nlI
Return Nil

/*##########################################################
#                 ___  "  ___                              #
#               ( ___ \|/ ___ ) Kazoolo                    #
#                ( __ /|\ __ )  Codefacttory               #
############################################################
#  Função :    # FAltKzM                                   # 
############################################################
# Parametros : # cAlias : Alias da tabela do browse        #
#              # nReg   : Recno do Registro na tabela      #   
#              # nOpc   : Opcao selecionada pelo usuario   #
############################################################
# Retorno :    # NIL                                       #
############################################################
# Descrição :  # Funcao responsavel pela estrutura da      #
#              # rotina. Nela e' criado tela, montagem do  #
#              # aHeader, aCols e etc...                   #
############################################################
# Autor :      # Demetrio Fontes De Los Rios               #
############################################################
# Data :       #  02/02/10                                 #
############################################################
# Palavras Chaves :  # Monta Modelo 3-Tela/aHeader/aCols   #
##########################################################*/
Static Function FAltKzM(cl1Tab,cl2Tab, nlRegAlt, alCampos, alVirtual, nlUsado)  
	Local nlI 		:= 0  
	local nlC		:= 0    
	Local nlRegPos 	:= 0    
	Local nlCont    := 0
	Local clVar     := "" 
	Local clFilCpo  := ""        
	Local c11Fil    := FSelCpoFi(cl1Tab)
	Local cl2Fil    := FSelCpoFi(cl2Tab)
	Local clFilial  := xFilial(cl1Tab)
                                                    
	If ( (nlRegPos:=Ascan(aHeader,{|x|"_REC_WT"$Alltrim(X[2])}))>0)
	    //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Altera Cabecalho         ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		dbSelectArea(cl1Tab) 
		&(cl1Tab)->(dbGotop())
		&(cl1Tab)->(dbGoTo(nlRegAlt))                     
		If RecLock(cl1Tab,INCLUI)  
			Replace &(cl1Tab+"->"+c11Fil) With clFilial
			For nlC:=1 to Len(alCampos) 
				If ( aScan(alVirtual,{|x| AllTrim(X[1])==AllTrim(alCampos[nlC])} )==0 )
					cl1Var := cl1Tab+"->"+alCampos[nlC] 
					cl2Var := "M->"+alCampos[nlC]
					Replace &cl1Var With &cl2Var	
				EndIf			                             
			Next nlC
			&(cl1Tab)->(MsUnLock()) 	
		EndIf  
		&(cl1Tab)->(dbCloseArea())   
	
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Altera Itens             ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ    
		For nlI:=1 to Len(aCols)    
			dbSelectArea(cl2Tab)     		
			&(cl2Tab)->(DbGoTop()) 
			If !aCols[nlI,nlUsado+1]   
				If aCols[nlI,nlRegPos]<>0
					&(cl2Tab)->(DbGoTo(aCols[nlI,nlRegPos]))     
					llRLock:=INCLUI
				Else            
					llRLock:=.T.   
					dbSelectArea(cl2Tab)
				EndIf					
				If RecLock(cl2Tab,llRLock)  
					Replace &(cl2Tab+"->"+cl2Fil) With clFilial
			  		For nlC:=1 to Len(aHeader)  
				  		FieldPut(FieldPos(aHeader[nlC][2]),aCols[nlI][nlC])
					Next nlC	
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	   				//³ Grava  Relacionamento    ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ    
					For nlCont:=1 to Len(aKzM3GrvR) 
						Replace &(aKzM3GrvR[nlCont,2]) With &(aKzM3GrvR[nlCont,1])			
					Next nlCont 
			    	&(cl2Tab)->(MsUnLock()) 	
				EndIf 		
			Else     
		  		If aCols[nlI,nlRegPos]<>0
					&(cl2Tab)->(DbGoTo(aCols[nlI,nlRegPos]))    
					If RecLock(cl2Tab,INCLUI)
	     		   		&(cl2Tab)->(dbDelete())
			   			&(cl2Tab)->(MsUnLock()) 	
					EndIf  	
				EndIf  
			EndIf		 
			dbSelectArea(cl2Tab)
			&(cl2Tab)->(dbCloseArea())
		Next nlI 
		For nlI := 1 To Len(aDeletados)
		   &(cL2Tab)->(DbGoTo(aDeletados[nLi]))
		   If &(cL2Tab)->(RecLock(cL2Tab, .F.))
              &(cl2Tab)->(dbDelete())
			  &(cl2Tab)->(MsUnLock())
		   EndIf
		Next
	EndIf  
Return Nil                                                   

/*##########################################################
#                 ___  "  ___                              #
#               ( ___ \|/ ___ ) Kazoolo                    #
#                ( __ /|\ __ )  Codefacttory               #
############################################################
#  Função :    # FSelCpoFi                                 # 
############################################################
# Parametros : # cAlias : Alias da tabela do browse        #
#              # nReg   : Recno do Registro na tabela      #   
#              # nOpc   : Opcao selecionada pelo usuario   #
############################################################
# Retorno :    # NIL                                       #
############################################################
# Descrição :  # Funcao responsavel pela estrutura da      #
#              # rotina. Nela e' criado tela, montagem do  #
#              # aHeader, aCols e etc...                   #
############################################################
# Autor :      # Demetrio Fontes De Los Rios               #
############################################################
# Data :       #  02/02/10                                 #
############################################################
# Palavras Chaves :  # Monta Modelo 3-Tela/aHeader/aCols   #
##########################################################*/
Static Function FSelCpoFi(clAlias)
	Local alArea := GetArea()
	Local clRet  := ""

	dbSelectArea("SX3")                                          
    SX3->(dbSetOrder(1))
    SX3->(dbGoTop())
	SX3->(dbSeek(clAlias))
	Do While !Eof().And.(SX3->X3_ARQUIVO==clAlias)     
		If "_FILIAL" $ SX3->X3_CAMPO
			clRet := X3_CAMPO  
			Exit
		EndIf
		SX3->(DbSkip())
	End Do 
	               
	RestArea(alArea)
Return clRet

/*##########################################################
#                 ___  "  ___                              #
#               ( ___ \|/ ___ ) Kazoolo                    #
#                ( __ /|\ __ )  Codefacttory               #
############################################################
#  Função :    # FDelKzM                                   # 
############################################################
# Parametros : # cAlias : Alias da tabela do browse        #
#              # nReg   : Recno do Registro na tabela      #   
#              # nOpc   : Opcao selecionada pelo usuario   #
############################################################
# Retorno :    # NIL                                       #
############################################################
# Descrição :  # Funcao responsavel pela estrutura da      #
#              # rotina. Nela e' criado tela, montagem do  #
#              # aHeader, aCols e etc...                   #
############################################################
# Autor :      # Demetrio Fontes De Los Rios               #
############################################################
# Data :       #  02/02/10                                 #
############################################################
# Palavras Chaves :  # Monta Modelo 3-Tela/aHeader/aCols   #
##########################################################*/
Static Function FDelKzM(cl1Tab,cl2Tab, nlRegDel)
	Local nlRegPos   := 0
	Local nlC        := 0  

	If ( (nlRegPos:=Ascan(aHeader,{|x|"_REC_WT"$Alltrim(X[2])}))>0)  
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Deleta Cabecalho         ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		dbSelectArea(cl1Tab) 
		&(cl1Tab)->(dbGotop())
		&(cl1Tab)->(dbGoTo(nlRegDel))            
		If RecLock(cl1Tab,INCLUI)
			&(cl1Tab)->(dbDelete())
			&(cl1Tab)->(MsUnLock()) 	
		EndIf  
		&(cl1Tab)->(dbCloseArea())
				
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Deleta Itens             ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ    
		For nlC:=1 to Len(aCols)    
			dbSelectArea(cl2Tab)     		
			&(cl2Tab)->(DbGoTop())
			&(cl2Tab)->(DbGoTo(aCols[nlC,nlRegPos]))     
			If RecLock(cl2Tab,INCLUI)
     		   		&(cl2Tab)->(dbDelete())
	   			&(cl2Tab)->(MsUnLock()) 	
			EndIf  		
			&(cl2Tab)->(dbCloseArea())
		Next nlC     
	Endif      
Return Nil                       


/*##########################################################
#                 ___  "  ___                              #
#               ( ___ \|/ ___ ) Kazoolo                    #
#                ( __ /|\ __ )  Codefacttory               #
############################################################
#  Função :    # FGetTitleAlia                             # 
############################################################
# Parametros : # cAlias : Alias da tabela do browse        #
#              # nReg   : Recno do Registro na tabela      #   
#              # nOpc   : Opcao selecionada pelo usuario   #
############################################################
# Retorno :    # NIL                                       #
############################################################
# Descrição :  # Funcao responsavel pela estrutura da      #
#              # rotina. Nela e' criado tela, montagem do  #
#              # aHeader, aCols e etc...                   #
############################################################
# Autor :      # Demetrio Fontes De Los Rios               #
############################################################
# Data :       #  02/02/10                                 #
############################################################
# Palavras Chaves :  # Monta Modelo 3-Tela/aHeader/aCols   #
##########################################################*/
Static Function FGetTitleAlia(clTabela)     
	Local clRet  := ""  
	Local alArea := GetArea()
	
	dbSelectArea("SX2")
	SX2->(dbSetOrder(1))
	If SX2->(dbSeek(clTabela))
		clRet := AllTrim(X2Nome())
	EndIf
	
	RestArea(alArea)
Return clRet

/*##########################################################
#                 ___  "  ___                              #
#               ( ___ \|/ ___ ) Kazoolo                    #
#                ( __ /|\ __ )  Codefacttory               #
############################################################
#  Função :    # AM103VLD()                                # 
############################################################
# Parametros : # nOpc :                                    #
############################################################
# Retorno :    # .T. ou .F.                                #
############################################################
# Descrição :  # VERIFICAÇÃO SE OS CAMPOS DO GET FORAM     #
#              # PREENCHIDOS                               #
############################################################
# Autor :      # Cleber Cintra Barbosa                     #
############################################################
# Data :       #  12/05/10                                 #
############################################################
# Palavras Chaves :  #                                     #
##########################################################*/       

Function AM103VLD(nlOpc)
	If nlOpc == 3 .Or. nlOpc == 4
	    If empty(aCols[N][gdFieldPos("EWH_CODSRV")])
	    	Aviso(STR0007,STR0008,{STR0009})
	    	Return .F.
	    Endif     
	EndIf
Return .T.

/*##########################################################
#                 ___  "  ___                              #
#               ( ___ \|/ ___ ) Kazoolo                    #
#                ( __ /|\ __ )  Codefacttory               #
############################################################
#  Função :    # AMPerg103()                                   # 
############################################################
# Parametros : # clPar : SITUAÇÃO DA DATA                  #
############################################################
# Descrição :  # VERIFICAÇÃO DOS CAMPOS DATA INICIAL, FINAL#
#              # E PREVISTA DO SERVIÇO, PARA DISPARO DOS GATILHOS#
############################################################
# Autor :      # Cleber Cintra Barbosa                     #
############################################################
# Data :       #  12/05/10                                 #
############################################################
# Palavras Chaves :  #                                     #
##########################################################*/

Function AM103Perg(clPar)
	Local alArea	:= GetArea()
	Local nlI	    := 0
	Local clCodTab	:= ""
	Private npLinha	:= 0
    
	IF M->EWG_CODTAB = Nil
	   M->EWG_CODTAB:= EWE->EWE_CODTAB
	   clCodTab:= M->EWG_CODTAB
	ELSE
	   clCodTab:= M->EWG_CODTAB
	ENDIF
	
	If clPar $ "IPF"
		M->EWG_VL_TOT := 0
		M->EWG_VL_PRV := 0
		For nlI := 1 to len(aCols)
			N := nlI
            
            If clPar = "I"
				aCols[nlI][gdFieldPos("EWH_DT_INI")] := M->EWG_DT_INI
			Elseif clPar = "P"
				aCols[nlI][gdFieldPos("EWH_PRVFIM")] := M->EWG_PRVFIM //FDR
			Else
				aCols[nlI][gdFieldPos("EWH_DT_FIM")] := M->EWG_DT_FIM //FDR
			Endif

	  		If ExistTrigger("EWH_CODSRV")
				RunTrigger(2,nlI,,"EWH_CODSRV")
			Endif
	
		    IF ExistTrigger("EWH_DIAS")
		 		RunTrigger(2,nlI,,"EWH_DIAS") 
		 	Endif
	
	  		IF ExistTrigger("EWH_PERIOD")
				RunTrigger(2,nlI,,"EWH_PERIOD") 
			Endif
	
	  		IF ExistTrigger("EWH_ALISS")
		 		RunTrigger(2,nlI,,"EWH_ALISS") 
		 	Endif
	
			IF ExistTrigger("EWH_PRCTOT")
				RunTrigger(2,nlI,,"EWH_PRCTOT")
			Endif

			IF ExistTrigger("EWH_PRCUNI")
				RunTrigger(2,nlI,,"EWH_PRCUNI") 
			Endif
	
			M->EWG_VL_TOT += aCols[nLI][gdFieldPos("EWH_VL_TOT")]
			M->EWG_VL_PRV += aCols[nLI][gdFieldPos("EWH_VL_PRV")]
		Next nLI
//	   	opGetDd:forceRefresh(.T.)
	   	opGetDd:oBrowse:Refresh()
		
    Else    
		If MsgYesNo(STR0010)
			FQAcols(,,3)
			RestArea(alArea)
			Return(clCodTab)
		Endif 
	Endif			
  	opGetDd:oBrowse:Refresh()
	
	RestArea(alArea)
Return()

/*##########################################################
#                 ___  "  ___                              #
#               ( ___ \|/ ___ ) Kazoolo                    #
#                ( __ /|\ __ )  Codefacttory               #
############################################################
#  Função :    # AM103POSIC()                              # 
############################################################
# Descrição :  # POSICIONA COM O CODIGO DA TABELA PARA RETORNO DA DESCRIÇÃO #
############################################################
# Autor :      # Cleber Cintra Barbosa                     #
############################################################
# Data :       #  12/05/10                                 #
############################################################
# Palavras Chaves :  #                                     #
##########################################################*/

Function AM103POSIC()
Return Posicione("EWE",1,xFilial("EWE") + EWG->EWG_CODARM + EWG->EWG_LOJARM + EWG->EWG_CODTAB,"EWE_DESTAB")

/*##########################################################
#                 ___  "  ___                              #
#               ( ___ \|/ ___ ) Kazoolo                    #
#                ( __ /|\ __ )  Codefacttory               #
############################################################
#  Função :    # AM103CalcGat()                                 # 
############################################################
# Descrição :  # REALIZA OS CALCULOS DOS GATILHOS A PARTIR #
#              # DOS CAMPOS DA ENCHOICE E GETDADOS         #
#              #                                           #
############################################################
# Autor :      # Cleber Cintra Barbosa                     #
############################################################
# Data :       #  12/05/10                                 #
############################################################
# Palavras Chaves :  #                                     #
##########################################################*/

Function AM103CalcGat(clRet)
	Local nlRet := 0
	Local nQtdDiasPrv, nQtdPer
	
	If clRet == "VLPRV"
	   //GFP 20/08/2010 14:25 - Inserido condição para preenchimento manual
	   If aCols[N][gdFieldPos("EWH_PERIOD")] > 0	                        
	       If Empty(aCols[N][gdFieldPos("EWH_PRVFIM")]) .Or. Empty(aCols[N][gdFieldPos("EWH_DT_INI")])
	          nQtdDiasPrv := 0
	       Else
	          nQtdDiasPrv := (aCols[N][gdFieldPos("EWH_PRVFIM")])-(aCols[N][gdFieldPos("EWH_DT_INI")])+1
	       EndIf
	       
              nQtdPer     := INT(nQtdDiasPrv/aCols[N][gdFieldPos("EWH_PERIOD")])+;
	                         IF(nQtdDiasPrv % aCols[N][gdFieldPos("EWH_PERIOD")]>0,1,0)
	   	                        
		    
		      nlRet:= Round((aCols[N][gdFieldPos("EWH_PRCTOT")])*(aCols[N][gdFieldPos("EWH_QTD")])*nQtdPer,AvSX3("EWH_VL_PRV",AV_DECIMAL))
    

	   EndIf
	   
	Elseif clRet == "ALISS"
		nlRet:= ((aCols[N][gdFieldPos("EWH_PRCUNI")])/((1-((aCols[N][gdFieldPos("EWH_ALISS")])/100))))
	
    Elseif clRet == "PER"                                                                                           
		//GFP 20/08/2010 14:25 - Inserido condição para preenchimento manual
		If aCols[N][gdFieldPos("EWH_PERIOD")] > 0
		   nlRet:= (INT((aCols[N][gdFieldPos("EWH_DIAS")])/(aCols[N][gdFieldPos("EWH_PERIOD")]))+IF((aCols[N][gdFieldPos("EWH_DIAS")])%(aCols[N][gdFieldPos("EWH_PERIOD")])>0,1,0))                  
		   clRet:= ""
		Endif	
   	
   	Elseif clRet == "PRC"
		nlRet:= Round((aCols[N][gdFieldPos("EWH_PRCTOT")])*(aCols[N][gdFieldPos("EWH_QTD")])*(aCols[N][gdFieldPos("EWH_QTDPER")]),AvSX3("EWH_VL_TOT",AV_DECIMAL))
			
	Elseif clRet == "PRCT"
		nlRet := (aCols[N][gdFieldPos("EWH_PRCTOT")])*(1-(aCols[N][gdFieldPos("EWH_ALISS")])/100)
	
	//GFP 19/08/2010 11:23 - Condição para calcular Valor Previsto com base em dias inseridos
	Elseif clRet == "QTD"
	   If aCols[N][gdFieldPos("EWH_PERIOD")] > 0
	      If Empty(aCols[N][gdFieldPos("EWH_PRVFIM")]) .Or. Empty(aCols[N][gdFieldPos("EWH_DT_INI")])
	         nQtdDiasPrv := 0
	      Else
	         nQtdDiasPrv := (aCols[N][gdFieldPos("EWH_PRVFIM")])-(aCols[N][gdFieldPos("EWH_DT_INI")])+1
	      EndIf 
	   
	      nQtdPer := INT(nQtdDiasPrv/aCols[N][gdFieldPos("EWH_PERIOD")])+;
	                 IF(nQtdDiasPrv % aCols[N][gdFieldPos("EWH_PERIOD")]>0,1,0)
	   	                        
	      
	      nlRet:= (aCols[N][gdFieldPos("EWH_PRCTOT")])*(aCols[N][gdFieldPos("EWH_QTD")])*nQtdPer
	      
	   
	   EndIF
	             
    //GFP 19/08/2010 15:27 - Condição para calcular Valor Total com base em dias inseridos
    ElseIf clRet == "QTD1"
       nlRet := (aCols[N][gdFieldPos("EWH_PRCTOT")])*(aCols[N][gdFieldPos("EWH_QTD")])*(aCols[N][gdFieldPos("EWH_QTDPER")])
  
  	//GFP 19/08/2010 15:41 - Condição para gatilhar Periodicidade com base em dias inseridos
	Elseif clRet == "DIAS"
	   nlRet := INT((aCols[N][gdFieldPos("EWH_DIAS")])/(aCols[N][gdFieldPos("EWH_PERIOD")]) + If((aCols[N][gdFieldPos("EWH_DIAS")])%(aCols[N][gdFieldPos("EWH_PERIOD")])>0,1,0),1 )

	Endif
	clRet:= ""
Return nlRet

/*##########################################################
#                 ___  "  ___                              #
#               ( ___ \|/ ___ ) Kazoolo                    #
#                ( __ /|\ __ )  Codefacttory               #
############################################################
#  Função :    # FTesteData                                # 
############################################################
# Parametros : # dDataTes :                                #
############################################################
# Retorno :    # dDataBase      	                       #
############################################################
# Descrição :  # FUNÇÃO TESTE PARA OS CAMPOS QUE DEVERÃO SER
#              # PREENCHIDOS DE ACORDO COM A NECESSIDADE DA EMPRESA
############################################################
# Autor :      # Cleber Cintra Barbosa                     #
############################################################
# Data :       #  12/05/10                                 #
############################################################
# Palavras Chaves :  #                                     #
##########################################################*/			

User Function FTesteData(dDataTes)
	Local clData := dDataTes
Return dDataBase

User Function FTesteD(dDataTes)
	Local clData := dDataTes
Return dDataBase+5

User Function Formula(clFormul)
	Local clAux:= 5*3	
Return clAux

/*##########################################################
#                 ___  "  ___                              #
#               ( ___ \|/ ___ ) Kazoolo                    #
#                ( __ /|\ __ )  Codefacttory               #
############################################################
#  Função :    # Retorno                                   # 
############################################################
# Parametros : # clRet :                                   #
############################################################
# Retorno :    # llReturn :.T. OU .F.                      #
############################################################
# Descrição :  # VERIFICAÇÃO DOS CAMPOS PARA VALORES NEGATIVOS
############################################################
# Autor :      # Cleber Cintra Barbosa                     #
############################################################
# Data :       #  12/05/10                                 #
############################################################
# Palavras Chaves :  #                                     #
##########################################################*/

Function RETORNO(clRet)
	Local llReturn:= .F.
	
	If clRet == "ALISS"
		If (aCols[N][gdFieldPos("EWH_PRCUNI")])>0
			llReturn := .T.                                  
		Endif
				
	Elseif clRet == "QTD"	
		If(aCols[N][gdFieldPos("EWH_DIAS")])>0 .AND. (aCols[N][gdFieldPos("EWH_PERIOD")])>0            
			llReturn:= .T.
		Endif
	
	Elseif clRet == "VLTOT"
		If (aCols[N][gdFieldPos("EWH_PRCTOT")])>0 .AND. (aCols[N][gdFieldPos("EWH_QTD")])>0 .AND. (aCols[N][gdFieldPos("EWH_QTDPER")])>0
			llReturn := .T.
		Endif
		
	Elseif clRet == "QTDP"
		If (aCols[N][gdFieldPos("EWH_DIAS")])>0
			llReturn := .T.                                       
		Endif

    //TRP - 20/08/2010
    Elseif clRet == "PER"
       	If (aCols[N][gdFieldPos("EWH_PERIOD")])>0
			llReturn := .T.                                       
		Endif   
    
    
    Endif
    //FDR - 06/04/2011
    If clRet == "EWG_DT_INI" .Or. clRet == "EWG_PRVFIM" .Or. clRet == "EWG_DT_FIM"
       If Empty(M->&(AllTrim(clRet)))
          llReturn := .F.
       ElseIf !Empty(M->EWG_DT_INI)
          llReturn := MsgYesNo("Deseja recalcular?","Aviso")
       Else
          MsgInfo("Se deseja recalcular preencha o campo da data inicial","Atenção")
       EndIf
    EndIf

	clRet:= ""
Return llReturn 

/*##########################################################
#                 ___  "  ___                              #
#               ( ___ \|/ ___ ) Kazoolo                    #
#                ( __ /|\ __ )  Codefacttory               #
############################################################
#  Função :    # AM103Ret                                       # 
############################################################
# Parametros : # clRet :.T. OU .F.                         #
############################################################
# Retorno :    # llReturn :                                #
############################################################
# Descrição :  # VERIFICAÇÃO DOS CAMPOS PARA VALORES NEGATIVOS
############################################################
# Autor :      # Cleber Cintra Barbosa                     #
############################################################
# Data :       #  12/05/10                                 #
############################################################
# Palavras Chaves :  #                                     #
##########################################################*/
Function AM103Ret(clRet)
	Local llReturn:= .F.
	Local nlRet		:= 0

	If clRet == "VLPR"
		If (aCols[N][gdFieldPos("EWH_QTD")])>0 .AND. (aCols[N][gdFieldPos("EWH_PERIOD")])>0
			llReturn := .T.
		Endif
    
    //GFP 19/08/2010 15:49 - Condição para validação de dias
	ElseIf clRet == "DIAS"
	    If ((aCols[N][gdFieldPos("EWH_DIAS")])>=Date())
	    	llReturn := .T.
		Endif   
				
	Elseif clRet == "PRC"
		nlRet:= (aCols[N][gdFieldPos("EWH_PRCTOT")])*(aCols[N][gdFieldPos("EWH_QTD")])*(aCols[N][gdFieldPos("EWH_QTDPER")])
		Return nlRet  
	
	Endif
	clRet:= ""
Return llReturn	
	
/*##########################################################
#                 ___  "  ___                              #
#               ( ___ \|/ ___ ) Kazoolo                    #
#                ( __ /|\ __ )  Codefacttory               #
############################################################
#  Função :    # AM103VADATE                               # 
############################################################
# Parametros : # clRet :                                   #
############################################################
# Retorno :    # .T. OU .F.                                         #
############################################################
# Descrição :  # VALIDAÇÃO DA DATA FINAL SER NÃO SER INFERIOR #
#              # A DATA ATUAL                              #
############################################################
# Autor :      # Cleber Cintra Barbosa                     #
############################################################
# Data :       #  12/05/10                                 #
############################################################
# Palavras Chaves :  #                                     #
##########################################################*/

Function AM103VADATE(clRet)
//	Local llReturn	:= .T.                              
	Local nlRet		:= 0
   /* -- Esses tratamentos foram efetutados na função validagetdados() - FDR       
	If clRet == "INI"
		//If !empty(aCols[N][gdFieldPos("EWH_DT_INI")])
			If (aCols[N][gdFieldPos("EWH_DT_INI")]) > (aCols[N][gdFieldPos("EWH_DT_FIM")])
				llreturn:= .F.
			Endif
		//Endif
		
    Elseif clRet == "FIM"
      //	If !empty(aCols[N][gdFieldPos("EWH_DT_FIM")])
			If (aCols[N][gdFieldPos("EWH_DT_FIM")]) < (aCols[N][gdFieldPos("EWH_DT_INI")])
				llreturn:= .F.
			Endif
	  //Endif
		                               
	Else*/
 	if clRet == "DIAS"
		If Empty(M->EWG_DT_INI)
			nlRet:= (iif(!Empty(EWD->EWD_CDTFIM),AM103EXEC("EWD->EWD_CDTFIM",ctod("//")),ctod("//")))-(  iif(!Empty(EWD->EWD_CDTINI),AM103EXEC("EWD->EWD_CDTINI",ctod("//")),ctod("//")))+1
//			Return nlRet	                                   
    	Else
			nlRet:= (aCols[N][gdFieldPos("EWH_DT_FIM")])-(aCols[N][gdFieldPos("EWH_DT_INI")])+1
  //			Return nlRet
		Endif    		
	Endif
//Return llReturn
Return nlRet

/*##########################################################
#                 ___  "  ___                              #
#               ( ___ \|/ ___ ) Kazoolo                    #
#                ( __ /|\ __ )  Codefacttory               #
############################################################
#  Função :    # AM103_Retor()                                # 
############################################################
# Retorno :    # clAux :                                   #
############################################################
# Descrição :  # VERIFICAÇÃO PARA CHAVE DE BUSCA DOS GATILHOS #
#              # SENDO POR VALORES DA TABELA OU VALORES DE MEMORIA #
############################################################
# Autor :      # Cleber Cintra Barbosa                     #
############################################################
# Data :       #  12/05/10                                 #
############################################################
# Palavras Chaves :  #                                     #
##########################################################*/

Function AM103_Retor()
	Local clAux:= ""                

	If "KZ_CODSRV" $ Upper(AllTrim(ReadVar()))
		clAux:= XFILIAL("EWD")+M->EWH_CODSRV
	Else
		clAux:= XFILIAL("EWD")+ (aCols[N][gdFieldPos("EWH_CODSRV")])
	Endif		
Return (clAux)
                   
/*##########################################################
#                 ___  "  ___                              #
#               ( ___ \|/ ___ ) Kazoolo                    #
#                ( __ /|\ __ )  Codefacttory               #
############################################################
#  Função :    # VLRTOT                                    # 


/*##########################################################
#                 ___  "  ___                              #
#               ( ___ \|/ ___ ) Kazoolo                    #
#                ( __ /|\ __ )  Codefacttory               #
############################################################
#  Função :    # AM103VLRTOT                                    # 
############################################################
# Retorno :    # nlVlr : VALOR TOTAL DO SERVIÇO            #
############################################################
# Descrição :  # CALCULO DO VALOR TOTAL DOS SERVIÇOS       #
############################################################
# Autor :      # Cleber Cintra Barbosa                     #
############################################################
# Data :       #  12/05/10                                 #
############################################################
# Palavras Chaves :  #                                     #
##########################################################*/

Function AM103VLRTOT()
    Local nlVlr := (aCols[N][gdFieldPos("EWH_PRCTOT")])*(aCols[N][gdFieldPos("EWH_QTD")])*(aCols[N][gdFieldPos("EWH_QTDPER")])
Return nlVlr                 
                                             
/*##########################################################
#                 ___  "  ___                              #
#               ( ___ \|/ ___ ) Kazoolo                    #
#                ( __ /|\ __ )  Codefacttory               #
############################################################
#  Função :    # FGrava                                    # 
############################################################
# Parametros : # nlOpc : OPÇÃO ESCOLHIDA INCLUSÃO, ALTERAÇÃO OU EXCLUSÃO#   
############################################################
# Retorno :    #                                           #
############################################################
# Descrição :  # GRAVAÇÃO DO O TITULO NO FINANCEIRO        #
############################################################
# Autor :      # Cleber Cintra Barbosa                     #
############################################################
# Data :       #  12/05/10                                 #
############################################################
# Palavras Chaves :  #                                     #
##########################################################*/

Static Function FGrava(nlOpc)
	Local nlRecno	:= 0
	Local nlPosRot	:= 0
	Local blExecSE2	:= {|| }
	Local lRetF050	:= .T.
	Local aDadosSE2 := {}
	Local lOperOk   := .T.
	Local lCriaSWD  := .F.
	Local lCriaSE2  := .F.

	// Variaveis para inicialização do titulo a pagar
	Private lMsErroAuto := .F.
	Private bIniciaVal
	Private cValidaOK:= " .AND. AM103FVldFor() "
	Private nValorS  := 0
	Private cCodFor		:= "" 
    Private cLojaFor	:= "" 
	Private cNumINV		:= "" 
	Private cNatureza	:= "" 
	Private dDataINV	:= dDatabase
	Private nMoedSubs   := 0
	Private nTaxaINV	:= 0
	Private nValorINV	:= 0

 	Do Case
 		Case nlOpc == 5
			dbSelectArea("SWD")
			dbSetOrder(1)
			dbGoTop()
			If dbSeek(xFILIAL("SWD")+M->EWG_HAWB+M->EWG_DESPESA)
				If !Empty(SWD->WD_CTRFIN1)
					dbSelectArea("SE2")
					dbSetOrder(1)
					If dbSeek(xFILIAL("SE2") + PadR(SWD->WD_PREFIXO,TamSx3("E2_PREFIXO")[1]) + PadR(SWD->WD_CTRFIN1,TamSx3("E2_NUM")[1]) + PadR(SWD->WD_PARCELA,TamSx3("E2_PARCELA")[1]) + PadR(SWD->WD_TIPO,TamSx3("E2_TIPO")[1]) + PadR(SWD->WD_FORN,TamSx3("E2_FORNECE")[1]) + PadR(SWD->WD_LOJA,TamSx3("E2_LOJA")[1]))
						aDadosSE2 := {}
						aAdd(aDadosSE2,{"E2_FILIAL" ,xFilial("SE2"),nil})
						aAdd(aDadosSE2,{"E2_PREFIXO",SE2->E2_PREFIXO,nil})
						aAdd(aDadosSE2,{"E2_NUM"    ,SE2->E2_NUM,nil})
						aAdd(aDadosSE2,{"E2_PARCELA",SE2->E2_PARCELA,nil})
						aAdd(aDadosSE2,{"E2_TIPO"   ,SE2->E2_TIPO,nil})
						aAdd(aDadosSE2,{"E2_FORNECE",SE2->E2_FORNECE,nil})
						aAdd(aDadosSE2,{"E2_LOJA"   ,SE2->E2_LOJA,nil})

						MsExecAuto({|x,y,z| FINA050(x,y,z)},aDadosSE2,,5)
						If lMsErroAuto
       						MostraErro()
       						lOperOk := .F.
				  		Endif
					Endif
				Endif

				If lOperOk
					If RecLock("SWD",.F.)
						dbDelete()
						MsUnLock()
					EndIf
				Endif
			EndIf
			
 		Case nlOpc == 4
			If Len(AllTrim(DtoS(M->EWG_DT_VEN))) > 0
				dbSelectArea("SWD")
				SWD->(dbSetOrder(1))
				SWD->(dbGoTop())
				If dbSeek(xFILIAL("SWD") + EWG->EWG_HAWB + EWG->EWG_DESPESA)
					If RecLock("SWD",.F.)
						SWD->WD_HAWB 	:= M->EWG_HAWB
						SWD->WD_DESPESA := M->EWG_DESPES
						SWD->WD_DES_ADI := M->EWG_DT_VEN
						SWD->WD_VALOR_R := M->EWG_VL_TOT
						SWD->WD_FORN 	:= M->EWG_CODARM
						SWD->WD_LOJA 	:= M->EWG_LOJARM				
						MsUnLock()
					EndIf

					If !Empty(SWD->WD_CTRFIN1)
						dbSelectArea("SE2")
						SE2->(dbSetOrder(1))
						SE2->(dbGoTop())
						If dbSeek(xFILIAL("SE2") + PadR(SWD->WD_PREFIXO,TamSx3("E2_PREFIXO")[1]) + PadR(SWD->WD_CTRFIN1,TamSx3("E2_NUM")[1]) + PadR(SWD->WD_PARCELA,TamSx3("E2_PARCELA")[1]) + PadR(SWD->WD_TIPO,TamSx3("E2_TIPO")[1]) + PadR(SWD->WD_FORN,TamSx3("E2_FORNECE")[1]) + PadR(SWD->WD_LOJA,TamSx3("E2_LOJA")[1]))
							If RecLock("SE2",.F.)
								SE2->E2_VENCTO	:= SWD->WD_DES_ADI
						        SE2->E2_VENCREA := SWD->WD_DES_ADI
						        SE2->E2_VALOR	:= SWD->WD_VALOR_R
						        SE2->E2_VLCRUZ	:= SWD->WD_VALOR_R
						        MsUnLock()
					        EndIf
					   	Else
					   		lCriaSE2 := .T.
						EndIf
					EndIf
				Else
					lCriaSWD := .T.
					lCriaSE2 := .T.
				EndIf
			EndIf

 		Case nlOpc == 3
			If !Empty(EWG_DT_VEN)
				lCriaSWD := .T.
				lCriaSE2 := .T.
			Endif
	End Case


	if lCriaSWD
		If Reclock("SWD",.T.)
			SWD->WD_FILIAL	:= xFilial("SWD") 
			SWD->WD_HAWB 	:= EWG_HAWB 
			SWD->WD_DESPESA := EWG_DESPES
			SWD->WD_DES_ADI := EWG_DT_VEN
			SWD->WD_VALOR_R := EWG_VL_TOT
			SWD->WD_FORN 	:= EWG_CODARM
			SWD->WD_LOJA 	:= EWG_LOJARM			
			SWD->WD_BASEADI := "2"
			SWD->WD_DT_NFC	:= CTOD("")
			SWD->WD_PAGOPOR	:= "1"
			SWD->WD_GERFIN	:= "2"
			SWD->WD_DA		:= IF(SW6->W6_TIPOFEC="DA","1","2")      
			SWD->WD_DTENVF	:= CTOD("")
			MsUnLock()			
		Endif
	Endif

	If lCriaSE2
				If EasyGParam("MV_EASYFIN") == "S"
					cCodFor		:= SWD->WD_FORN
					cLojaFor	:= SWD->WD_LOJA 			
			
					bIniciaVal:={|| AM103FCSE2() }
	
			//Chama a inclusao do titulo
			bExecuta  := {|| nlPosRot:=ASCAN(aRotina, {|R| UPPER(R[2])=UPPER("FA050Inclu")}) ,;
			                lRetF050:=FA050Inclu("SE2",SE2->(RECNO()),IF(nlPosRot=0,3,nlPosRot) )=1,;
                					IF(lRetF050, nlRecno := SE2->(RECNO()), nlRecno := 0) } 
                					
			Fina050(,,,bExecuta )

			If lRetF050
				If RecLock("SWD",.F.)
					SWD->WD_PREFIXO	:= SE2->E2_PREFIXO
					SWD->WD_CTRFIN1	:= SE2->E2_NUM
					SWD->WD_PARCELA	:= SE2->E2_PARCELA
					SWD->WD_TIPO	:= SE2->E2_TIPO
				EndIf	        			
			EndIf
		EndIf
	Endif
Return lOperOk

/*##########################################################
#                 ___  "  ___                              #
#               ( ___ \|/ ___ ) Kazoolo                    #
#                ( __ /|\ __ )  Codefacttory               #
############################################################
#  Função :    # AM103FCSE2                                   # 
############################################################
# Retorno :    #                                           #
############################################################
# Descrição :  # CARREGA OS DADOS PRE-PREENCHIDOS DO TITULO#
############################################################
# Autor :      # Cleber Cintra Barbosa                     #
############################################################
# Data :       #  12/05/10                                 #
############################################################
# Palavras Chaves :  #                                     #
##########################################################*/
		
Function AM103FCSE2()
	M->E2_PREFIXO	:= "EIC"
	M->E2_NUM		:= GETSX8NUM("SE2","E2_NUM")
	M->E2_PARCELA	:= "A"
	M->E2_HIST		:= "P:" + AllTrim(SW6->W6_HAWB) + ' ' + Posicione("SYB",1,XFILIAL("SYB")+EWG->EWG_DESPES,"SYB->YB_DESCR")
	M->E2_TIPO		:= "NF"
	M->E2_FORNECE	:= SWD->WD_FORN
	M->E2_LOJA		:= SWD->WD_LOJA
	M->E2_EMISSAO	:= dDataBase
	M->E2_MOEDA		:= 1
	M->E2_VENCTO	:= SWD->WD_DES_ADI
	M->E2_VENCREA	:= DataValida(SWD->WD_DES_ADI,.T.)
	M->E2_ORIGEM	:= "SIGAEIC"
	M->E2_VALOR		:= SWD->WD_VALOR_R
	M->E2_VLCRUZ	:= SWD->WD_VALOR_R
	M->E2_HAWBEIC	:= SWD->WD_HAWB
Return()


/*##########################################################
#                 ___  "  ___                              #
#               ( ___ \|/ ___ ) Kazoolo                    #
#                ( __ /|\ __ )  Codefacttory               #
############################################################
#  Função :    # AM103FVldFor                                   # 
############################################################
# Retorno :    # llRet :                                   #
############################################################
# Descrição :  # VALIDAÇÃO PARA ALTERAÇÃO DO FORNECEDOR OU LOJA #
############################################################
# Autor :      # Cleber Cintra Barbosa                     #
############################################################
# Data :       #  12/05/10                                 #
############################################################
# Palavras Chaves :  #                                     #
##########################################################*/

Function AM103FVldFor()
	Local llRet	:= .T.
	
	If M->E2_FORNECE <> EWG->EWG_CODARM .Or. M->E2_LOJA <> EWG->EWG_LOJARM
		Aviso(STR0007,STR0011,{STR0009} )
		llRet	:= .F.
	EndIf			 
Return(llRet)

/*##########################################################
#                 ___  "  ___                              #
#               ( ___ \|/ ___ ) Kazoolo                    #
#                ( __ /|\ __ )  Codefacttory               #
############################################################
#  Função :    # AM103TOK                                  # 
############################################################
# Retorno :    # llRet                                     #
############################################################
# Descrição :  # VALIDAÇÃO DO TUDO OK                      #
############################################################
# Autor :      # Denis Francisco Tofoli                    #
############################################################
# Data :       #  14/05/10                                 #
############################################################
# Palavras Chaves :  #                                     #
##########################################################*/
Function AM103TOK(nOpcTOk)
	Local aArea := GetArea() 
	Local lRet  := .T.

	if nOpcTOk = 4 .OR. nOpcTOk = 5
		if !Empty(DTOS(dpDt_Ven)) // Significa que gerou SWD
	
			dbSelectArea("SWD")
			SWD->(dbSetOrder(1))
			SWD->(dbGoTop())
	
			If dbSeek(xFILIAL("SWD") + cpHAWB + cpDespes + DTOS(dpDt_Ven))
				IF !Empty(SWD->WD_CTRFIN1) // Significa que gerou SE2
					dbSelectArea("SE2")
					SE2->(dbSetOrder(1))
					SE2->(dbGoTop())
					If dbSeek(xFILIAL("SE2") + PadR(SWD->WD_PREFIXO,TamSx3("E2_PREFIXO")[1]) + PadR(SWD->WD_CTRFIN1,TamSx3("E2_NUM")[1]) + PadR(SWD->WD_PARCELA,TamSx3("E2_PARCELA")[1]) + PadR(SWD->WD_TIPO,TamSx3("E2_TIPO")[1]) + PadR(SWD->WD_FORN,TamSx3("E2_FORNECE")[1]) + PadR(SWD->WD_LOJA,TamSx3("E2_LOJA")[1]))
						If !Empty(DtoS(SE2->E2_BAIXA)) .OR. (SE2->E2_SALDO < SE2->E2_VALOR)
							lRet := .F.
						EndIf
					EndIf
				Endif
			EndIf
		Endif
	Endif

	if !lRet
		Aviso(STR0012,STR0013,{STR0009})
	Endif

	RestArea(aArea)   
Return lRet 

/*##########################################################
#                 ___  "  ___                              #
#               ( ___ \|/ ___ ) Kazoolo                    #
#                ( __ /|\ __ )  Codefacttory               #
############################################################
#  Função :    # AM103FORM                                    # 
############################################################
# Retorno :    # uRet                                      #
############################################################
# Descrição :  # Executa um formula fazendo tratamento de  #
#              # erro                                      #
############################################################
# Autor :      # Denis Francisco Tofoli                    #
############################################################
# Data :       #  24/05/10                                 #
############################################################
# Palavras Chaves :  # FORMULA, ERRO                       #
##########################################################*/
/*
Static Function AM103FORM(cForm,uPad)
	Local bBlock := ErrorBlock()
	Local uRet   := uPad

	bErro := ErrorBlock( { |e| ChecErr260(e,cForm),uRet:=uPad } )
	BEGIN SEQUENCE
		uRet := &cForm
	END SEQUENCE

	ErrorBlock(bBlock)
Return uRet
*/

Function Am103Exec(cCampo, uRetPad)
Local xRet := Nil
Local bBlock := ErrorBlock()
Local uRet   := uRetPad
Local cExpression := &cCampo

	bErro := ErrorBlock( { |e| Am103ChkErr(e, Alltrim(cCampo)), uRet := uRetPad } )
	BEGIN SEQUENCE
		xRet := &cExpression
	END SEQUENCE

	ErrorBlock(bBlock)

Return xRet

Function Am103ChkErr(e, cCampo)
Local cMsg := ""
Local nAt
Local lDic := .F.

   SX3->(DbSetorder(2))
   If e:gencode > 0
      If At("_", cCampo) > 0
         cCpoDic := cCampo
         If (nAt := At("-", cCpoDic)) > 0
            cCpoDic := SubStr(cCpoDic, nAt + 2)
         EndIf
         If SX3->(DbSeek(cCpoDic))
            cCampo := cCpoDic
            lDic := .T.
         EndIf
      EndIf
      If lDic
         cMsg += StrTran("Foi encontrado o seguinte erro ao executar o conteúdo do campo '###':", "###", AllTrim(cCampo)) + ENTER
         cMsg += "Erro: " + e:Description + ENTER
         cMsg += StrTran("Solução: Acesse a rotina '###' e corrija a expressão cadastrada.", "###", TabName(cCampo))
         MsgStop(cMsg, "Atenção")
      Else
         cMsg += StrTran("Foi encontrado o seguinte erro ao executar a expressão '###':", "###", &(cCampo)) + ENTER
         cMsg += "Erro: " + e:Description + ENTER
         cMsg += "Solução: Corrija a expressão informada."
         MsgStop(cMsg, "Atenção")      
      EndIf
   EndIf

Return .F.

Static Function TabName(cCampo)
   
   SX3->(DbSetOrder(2))
   If SX3->(DbSeek(cCampo))
      If SX2->(DbSeek(SX3->X3_ARQUIVO))
         Return AllTrim(X2Nome())
      EndIf
   EndIf

Return ""

/*##########################################################
#                 ___  "  ___                              #
#               ( ___ \|/ ___ ) Kazoolo                    #
#                ( __ /|\ __ )  Codefacttory               #
############################################################
#  Função :    # KZPRU                                     # 
############################################################
# Retorno :    # uRet                                      #
############################################################
# Descrição :  # Executa um formula fazendo tratamento de  #
#              # erro                                      #
############################################################
# Autor :      # Denis Francisco Tofoli                    #
############################################################
# Data :       #  24/05/10                                 #
############################################################
# Palavras Chaves :  # FORMULA, ERRO                       #
##########################################################*/
User Function AM103PRU()
	Local alArea     := GetArea()
	Local clSql      := Space(0)
	Local clAliasQry := Space(0)
	Local nRet       := 0
     
	clSql := "SELECT EWF_PRCUNI FROM "+RetSqlName("EWF")
	clSql += " WHERE D_E_L_E_T_ = ' '"
	clSql += " AND   EWF_FILIAL = '"+xFilial("EWF")+"'"
	clSql += " AND   EWF_CODARM = '"+M->EWG_CODARM+"'"
	clSql += " AND   EWF_LOJARM = '"+M->EWG_LOJARM+"'"
	clSql += " AND   EWF_CODTAB = '"+M->EWG_CODTAB+"'"
	
	If !Empty(aCols[N][gdFieldPos("EWH_CODSRV")]) 
	   clSql += " AND   EWF_CODSRV = '"+aCols[N][gdFieldPos("EWH_CODSRV")]+"'"
	EndIf
	
	If !Empty(aCols[N][gdFieldPos("EWH_LINHA")])
	   clSql += " AND   EWF_LINHA = '"+aCols[N][gdFieldPos("EWH_LINHA")]+"'"
	EndIf

	clAliasQry := GetNextAlias()
	dbUseArea(.T., "TOPCONN", TCGenQry(,,clSql),clAliasQry, .T., .T.)
	dbSelectArea(clAliasQry)
	If !eof()
		nRet := EWF_PRCUNI
	Endif
	dbCloseArea()

	RestArea(alArea)
Return nRet

User Function ValCols(cNomCpo)
	Local uVal := aCols[n,aScan(aHeader,{|x| Alltrim(x[2]) == cNomCpo })]
Return uVal

/*
Função    : ValidaGetDados()   
Objetivos : Validar os campos de data e quantidade na GetDados
Parametros: cField - Campo da GetDados que será validado.         
Retorno   : Lógico
Autor     : Flavio Danilo Ricardo - FDR
Revisão   : 
Data      : 15/04/11
*/

Function ValidaGetDados(cField)
Local lRet:= .T.
Local cCampo:= ""
Local i := 0

If cField = NIL
   cCampo := Right(ReadVar(),Len(ReadVar())-3)
Else
   cCampo := cField
EndIf

Begin Sequence

If cCampo == "EWH_QTD"
   If M->&(cCampo) == 0
      lRet:= .F.
      Break
   EndIf
EndIf


If (cCampo == "EWH_DT_FIM" .Or. cCampo == "EWH_PRVFIM")

   dDataIni := aCols[N,aScan(aHeader,{|x| Alltrim(x[2]) == 'EWH_DT_INI' })]  
   If M->&(cCampo) < dDataIni .And. !EMPTY(dDataIni)
      Alert("A data informada deverá ser maior que a data inicial.")
      lRet := .F.
      Break
   EndIf

   If cCampo == "EWH_DT_FIM"
      nDias := 0
      nDias := CalcDias("EWH_DT_FIM")
      If nDias <> 0
         aCols[N,aScan(aHeader,{|x| Alltrim(x[2]) == 'EWH_DIAS' })] := nDias
         If aCols[N,aScan(aHeader,{|x| Alltrim(x[2]) == 'EWH_PERIOD' })] > 0
            aCols[N,aScan(aHeader,{|x| Alltrim(x[2]) == 'EWH_QTDPER' })]:= (INT(nDias/(aCols[N][gdFieldPos("EWH_PERIOD")]))+IF(nDias%(aCols[N,aScan(aHeader,{|x| Alltrim(x[2]) == 'EWH_PERIOD' })])>0,1,0))                  
         Endif	
      EndIf
   EndIf 
EndIf 

If cCampo == "EWH_DT_INI"

   dDataFim := aCols[N,aScan(aHeader,{|x| Alltrim(x[2]) == 'EWH_DT_FIM' })]
   If !Empty(dDataFim) .And. M->&(cCampo) > dDataFim
      Alert("A data inicial deverá ser menor que a data final.")
      lRet := .F.
      Break
   EndIf

   nDias := 0
   nDias := CalcDias("EWH_DT_INI")
   If nDias <> 0
      aCols[N,aScan(aHeader,{|x| Alltrim(x[2]) == 'EWH_DIAS' })] := nDias
      If aCols[N,aScan(aHeader,{|x| Alltrim(x[2]) == 'EWH_PERIOD' })] > 0
		 aCols[N,aScan(aHeader,{|x| Alltrim(x[2]) == 'EWH_QTDPER' })]:= (INT(nDias/(aCols[N][gdFieldPos("EWH_PERIOD")]))+IF(nDias%(aCols[N,aScan(aHeader,{|x| Alltrim(x[2]) == 'EWH_PERIOD' })])>0,1,0))                  
      Endif	
   EndIf
EndIf

End Sequence
                                               	
Return lRet

/*
Função    : ValidEnch()   
Objetivos : Validar os campos de data da Enchoice
Parametros: cField - Campo da Enchoice que será validado.         
Retorno   : Lógico
Autor     : Flavio Danilo Ricardo - FDR
Revisão   : 
Data      : 15/04/11
*/

Function ValidEnch(cField)
Local lRet := .F.

Begin Sequence

If cField == "EWG_DT_FIM" .Or. cField == "EWG_PRVFIM" 

   dDataIni := M->EWG_DT_INI 
   If !EMPTY(dDataIni) .And. !Empty(M->&(cField)) .And. M->&(cField) < dDataIni
      Alert("A data informada deverá ser maior que a data inicial.")
      Break                  
   EndIf
 
EndIf

If cField == "EWG_DT_INI"
   dDataFim := M->EWG_DT_FIM
   If !Empty(dDataFim) .And. M->&(cField) > dDataFim
      Alert("A data inicial deverá ser menor que a data final.")
      Break
   EndIf
EndIf

lRet := .T.

End Sequence

Return lRet

/*
Função    : CalcDias()   
Objetivos : Calcular quantidade de dias
Parametros: cCampo - Campo utilizado para cálculo
Retorno   : Número de dias
Autor     : Flavio Danilo Ricardo - FDR
Revisão   : 
Data      : 15/04/11
*/
Function CalcDias(cCampo)
Local nRetorno := 1

If cCampo == "EWH_DT_FIM"
   dDataIni := aCols[N,aScan(aHeader,{|x| Alltrim(x[2]) == 'EWH_DT_INI' })]
   dDataFim := M->EWH_DT_FIM
EndIf

If cCampo == "EWH_DT_INI"
   dDataIni := M->EWH_DT_INI
   dDataFim := aCols[N,aScan(aHeader,{|x| Alltrim(x[2]) == 'EWH_DT_FIM' })]
EndIf

If !Empty(dDataIni) .And. !Empty(dDataFim)
   nRetorno := dDataFim - dDataIni
   If nRetorno == 0
      nRetorno := 1
   EndIf
EndIf

Return nRetorno
             
/*
Função    : GatVlGetDados()   
Objetivos : Atualizar a enchoice com o valor que estiver na GetDados
Parametros: cCampo - Campo da GetDados que será utilizado para atualização
Retorno   : -
Autor     : Flavio Danilo Ricardo - FDR
Revisão   : 
Data      : 15/04/11
*/             
Function GatVlGetDados(cCampo)
Local nValor := 0
Local i := 0

For i:=1 To Len(aCols)
   nValor += aCols[i,aScan(aHeader,{|x| Alltrim(x[2]) == cCampo })]
Next
       
If cCampo == "EWH_VL_TOT"
   M->EWG_VL_TOT := nValor
ElseIf cCampo == "EWH_VL_PRV"
   M->EWG_VL_PRV := nValor
EndIF
olEnch:Refresh()
        
Return 
