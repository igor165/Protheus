#INCLUDE "RWMAKE.CH" 
#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOPCONN.CH" 
#INCLUDE "EICAM100.CH" 
#Include "AVERAGE.CH"

/*##########################################################
#                 ___  "  ___                              #
#               ( ___ \|/ ___ ) Kazoolo                    #
#                ( __ /|\ __ )  Codefacttory               #
############################################################
#  Função :    # EICAM100                                   # 
############################################################
# Parametros : #                                           #
############################################################
# Retorno :    # NIL                                       #
############################################################
# Descrição :  # CHAMADA PARA CRIAÇÃO DA TELA              #
#              #                                           #
#              #                                           #
############################################################
# Autor :      # Cleber Cintra Barbosa                     #
############################################################
# Data :       #  12/05/10                                 #
############################################################
# Palavras Chaves :  #                                     #
##########################################################*/

Function EICAM100()
	
	Local alGetDados := {"AllwaysTrue" , "AllwaysTrue" ,,,,,5,"AllwaysTrue",,}
    Local alMemo     := {{"EWE","EWE_OBS"}}
	Local alCampos	 := {"EWE_CODARM","EWE_LOJARM","EWE_DESARM","EWE_CODTAB","EWE_DESTAB","EWE_"}
	Local alRelac	 := {}
	
	aAdd(alRelac,{"EWE_CODARM","EWF_CODARM"})
	aAdd(alRelac,{"EWE_LOJARM","EWF_LOJARM"})
	aAdd(alRelac,{"EWE_CODTAB","EWF_CODTAB"})	               	

    
	If Select("EWE") < 0
		Aviso(STR0007,STR0008,{STR0014})
		Return .F.
	EndIf


	AM100_Mod3("EWE",1,"EWF",1,alRelac, alCampos , alGetDados, 		, alMemo)                                       	
	
Return Nil                                                                                                       

/*##########################################################
#                 ___  "  ___                              #
#               ( ___ \|/ ___ ) Kazoolo                    #
#                ( __ /|\ __ )  Codefacttory               #
############################################################
#  Função :    # AM100_Mod3                                # 
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
# Descrição :  # MONTAGEM DA TELA COM ENCJOICE E GETDADOS  #
############################################################
# Autor :      # Cleber Cintra Barbosa                     #
############################################################
# Data :       #  12/05/10                                 #
############################################################*/ 

Function AM100_Mod3(clTab1,nl1Ord,clTab2,nl2Ord,alRelacGrv,alEnchoice,alGetDados,alBtnsBar,alMemo)
                                         
	Local nlCont        := 0              
	Local alBtRot       := {}                     
	Local clRetGet      := FGetTitleAlias(clTab1)               
	Private aKzM3Info   := {{clTab1,nl1Ord},{clTab2,nl2Ord}}    
	Private aKzM3Ench   := aClone(alEnchoice)                   
	Private aKzM3GetD   := aClone(alGetDados)     				
	Private aKzM3Btns   := aClone(alBtnsBar)    
	Private aKzM3GrvR   := aClone(alRelacGrv)         
	Private aKzM3Memo   := aClone(alMemo)
	Private aKzM3Visu   := {}
	Private cDelFunc 	:= ".T." 
	Private cCadastro 	:= "Cadastro de Preços de Armazenagem"
	Private aRotina 	:= { 	{"Pesquisar" 	,""				    ,0,1} ,;
	             				{"Visualizar" 	,"AM100Mod103"	,0,2} ,;
	             				{"Incluir" 		,"AM100Mod103"	,0,3} ,;
	           					{"Alterar" 		,"AM100Mod103"	,0,4} ,;
	             				{"Excluir" 		,"AM100Mod103"	,0,5} }
                         
	For nlCont:=1 to Len(alBtRot)
		aAdd(aRotina,alBtRot[nlCont])
	Next nlCont      
	
	dbSelectArea(clTab1)
	dbSetOrder(nl1Ord)
	mBrowse( 6,1,22,75,clTab1)
	
Return Nil    

/*##########################################################
#                 ___  "  ___                              #
#               ( ___ \|/ ___ ) Kazoolo                    #
#                ( __ /|\ __ )  Codefacttory               #
############################################################
#  Função :    # AM100Mod103                               # 
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
Function AM100Mod103(cAlias,nReg,nOpc)  
                                                                   
	Local alMSSize  := MsAdvSize(,.F.,430)  
	Local clTitle   := cCadastro
	Local nlDlgHgt 	:= 0
	Local nlGDHgt   := 0
	Local alCorTel  := {alMSSize[7],0,alMSSize[6],alMSSize[5]}
	Local nlSizeHd  := 350
	Local olDlg		:= NIL
	Local olEnch    := NIL
	Local olGetDd   := NIL
	Local clAwTrue  := "AllwaysTrue()"
	Local cl1Alias  := aKzM3Info[1,1]
	Local cl2Alias  := aKzM3Info[2,1]
	Local nlOr2     := aKzM3Info[2,2]
                   
	Local alAltEnch := Iif(  (Type("aKzM3Ench[1]")<>"A") ,NIL      , aKzM3Ench[01] )
	Local nlModEnch := Iif(  (Type("aKzM3Ench[2]")<>"N") ,1        , aKzM3Ench[02] )
	Local clENTdOk  := Iif(  (Type("aKzM3Ench[3]")<>"C") ,clAwTrue , aKzM3Ench[03] )
	Local llVerObg  := Iif(  (Type("aKzM3Ench[4]")<>"L") ,.T.      , aKzM3Ench[04] )
	Local llColumn  := Iif(  (Type("aKzM3Ench[5]")<>"L") ,.F.      , aKzM3Ench[05] )
	Local llObgOk   := .F.  
	Local alEncVirt := {}

	Local clLinOk   := Iif( (Type("aKzM3GetD[01]")<>"C"), clAwTrue 		,  aKzM3GetD[01]  )
	Local clTdOk    := Iif( (Type("aKzM3GetD[02]")<>"C"), .T.			,  aKzM3GetD[02]  )
	Local clCpoIni  := Iif( (Type("aKzM3GetD[03]")<>"C"), NIL			,  aKzM3GetD[03]  )
	Local llDelGd   := Iif( (Type("aKzM3GetD[04]")<>"L"), .T.      		,  aKzM3GetD[04]  )
	Local aAltGd    := Iif( (Type("aKzM3GetD[05]")<>"A"), NIL      		,  aKzM3GetD[05]  )
	Local llEmptyGd := Iif( (Type("aKzM3GetD[06]")<>"L"), .F.      		,  aKzM3GetD[06]  )
	Local nlMaxLLin := Iif( (Type("aKzM3GetD[07]")<>"N"), 99       		,  aKzM3GetD[07]  )
	Local clFilOkGd := Iif( (Type("aKzM3GetD[08]")<>"C"), NIL	      	,  aKzM3GetD[08]  )
	Local clSDelGd  := Iif( (Type("aKzM3GetD[09]")<>"C"), NIL      		,  aKzM3GetD[09]  )
	Local clDelOkGd := Iif( (Type("aKzM3GetD[10]")<>"C"), NIL      		,  aKzM3GetD[10]  )
	
	Local llDelBar  := Iif((nOpc==5),.T.,.F.)
	Local alBtEnBar := {}
	
	Local alSize    := {} 
	Local nlCont    := 0 
	Local alCpoEnch := {}       
	Local aTitulos  := {}
 

	Local nlUsado   	:= 0
	Local alHVtCpo  	:= {}
	Local alHVsCpo  	:= {}
	Local alNotCpH  	:= {}
	

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
                     
	if DELETA
		if !AM100DEL()
			ApMsgStop(STR0015)
			Return
		Endif
	Endif
   	aHeader := GdMontaHeader(  		@nlUsado     	,;
  									@alHVtCpo       ,;
  									@alHVsCpo       ,;
  									cl2aLias        ,;
  									{"EWF_CODARM","EWF_LOJARM","EWF_CODTAB"},;
  									.F.             ,;
  									.F.             ,;
  									.F.             ,;
  									NIL             ,;
  									.T.             ,;
  									.T.             ,;
  									.F.             ,;
  									.F.             ,)               							
  	
	If INCLUI .Or. (FMQAcols(cl1aLias,cl2aLias) .And. KZL->(EOF()))
  	
  		aAdd(aCols,Array(nlUsado+1))    
  		For nlCont:=1 to nlUsado  
  			If !("_REC_WT"$aHeader[nlCont,2]) .AND. !("_ALI_WT"$aHeader[nlCont,2])    
	  			aCols[Len(aCols),nlCont]:=CriaVar(aHeader[nlCont,2])
  			EndIf
  		Next nlCont                                                   
  		aCols[(Len(aCols)),(nlUsado+1)] := .F.
  		
  	Else
  	   	While KZL->(!EOF())
			aADD(aCols,Array(nlUsado + 1))
			For nlCont := 1 to len(aHeader)  
				If "_REC_WT"$aHeader[nlCont,2]
					aCols[Len(aCols),nlCont] := KZL->R_E_C_N_O_
				ElseIf "_ALI_WT"$aHeader[nlCont,2]
					aCols[Len(aCols),nlCont] := cl2aLias  
				Else
					aCols[Len(aCols),nlCont] := FieldGet(FieldPos(aHeader[nlCont][2]))      
				EndIf
				aCols[Len(aCols),len(aHeader)+1] := .F. 
			   	If "EWF_DESSRV"$aHeader[nlCont,2]
					aCols[Len(aCols),nlCont] := Posicione("EWD",1,xFilial("EWD")+aCols[Len(aCols),aScan(aHeader,{|x| Alltrim(x[2]) == "EWF_CODSRV" })],"EWD_DESSRV")
				EndIf
				If "EWF_DESPRC"$aHeader[nlCont,2]
					aCols[Len(aCols),nlCont] := Posicione("EW8",1,XFILIAL("EW8")+aCols[Len(aCols),aScan(aHeader,{|x| Alltrim(x[2]) == "EWF_CODPRC" })],"EW8_DESPRC")
				EndIf
			Next nlCont		
			KZL->(DbSkip())
		EndDo     
	EndIf 
	If Select("KZL") > 0
		KZL->(dbCloseArea())
	EndIf 	

    dbSelectArea("SX3")                                          
    SX3->(dbSetOrder(1))
    SX3->(dbGoTop())
	SX3->(dbSeek(cl1Alias))
	alCpoEnch:={}
	Do While !Eof().And.(SX3->X3_ARQUIVO==cl1Alias)     
		If X3USO(SX3->X3_USADO).And.cNivel>=SX3->X3_NIVEL
			Aadd(alCpoEnch, ALLTRIM(X3_CAMPO)   )
			Aadd(aTitulos , ALLTRIM(X3TITULO()) )   
			If SX3->X3_CONTEXTT=="V"
				aAdd( alEncVirt , {ALLTRIM(X3_CAMPO), ALLTRIM(X3_TIPO)}  ) 
			EndIf
		Endif
		SX3->(DbSkip())
	End Do
	
	aCols[1][1]:= "001" 
						

	DEFINE MSDIALOG olDlg TITLE clTitle FROM alCorTel[1],alCorTel[2] TO alCorTel[3],alCorTel[4] PIXEL of oMainWnd 

		dbSelectArea(cl1Alias)    
        RegToMemory(cl1Alias,INCLUI,.T.,.T.) 
		olEnch 	:= Msmget():New(cl1Alias,nReg ,nOpc ,     ,      ,       ,alCpoEnch ,{15,1,70,315} ,alAltEnch    ,nlModEnch ,         ,          ,clENTdOk ,olDlg  ,   ,        , llColumn       ,       ,          ,  ,,,,.T.)    

		olGetDd := MsGetDados():New(45   ,1     ,nlGDHgt ,315    ,nOpc ,clLinOk ,clTdOk ,"+EWF_LINHA" ,llDelGd ,aAltGd ,      ,llEmptyGd ,/*nlMaxLLin*/   ,clSDelGd ,      ,clDelOkGd      ,       ,)        

                                                                                                                                     /*FDR*/
	ACTIVATE MSDIALOG olDlg ON INIT (EnchoiceBar(olDlg, {|| Iif((!VISUAL),( (llObgOk:=Iif(llVerObg,Obrigatorio(aGets,aTela,aTitulos).AND.ContaCols(),!llVerObg)),;
	 (Iif(llObgOk,(IIf(AM100VLD(),(FExec(cl1Alias, cl2Alias, nlUsado, nReg, alCpoEnch, alEncVirt, nlOr2),ConfirmSx8(),Close(olDlg)),NIL)),)), ),Close(olDlg))  },;
														{|| Close(olDlg), RollBackSx8()      },; 
														llDelBar,;
														alBtEnBar),AlignObject(olDlg,{olEnch:oBox,olGetDd:oBrowse},1,,alSize))
Return Nil

                                                                                                                                 
   
/*##########################################################
#                 ___  "  ___                              #
#               ( ___ \|/ ___ ) Kazoolo                    #
#                ( __ /|\ __ )  Codefacttory               #
############################################################
#  Função :    # FMQAcols                                  # 
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
Static Function FMQAcols(clCabcAlias, clItnsAlias) 
    
	Local clQuery 	:= ""     
	Local nlJ     	:= 0
    Local nlTamCond	:= Len(aKzM3GrvR)
      
	clQuery := "" 
    clQuery += " SELECT * "
    clQuery += " FROM "  + RetSqlName(clItnsAlias)+Space(1)+clItnsAlias
    clQuery += " WHERE " + clItnsAlias +".D_E_L_E_T_ = '"+Space(1)+"' "      
    clQuery += " AND " + FSelCpoFil(clItnsAlias) + "= '" + xFilial(clCabcAlias) + "' "
	    
    While (nlJ < nlTamCond)
    	nlJ++
    	clQuery += " AND ( " 
    	clQuery += aKzM3GrvR[nlJ,2] + "= '" + &(clCabcAlias+"->"+aKzM3GrvR[nlJ,1]) + "' "
    	clQuery += " ) "	     
    EndDo             
    
    TcQuery clQuery new Alias "KZL" 
    dbSelectArea("KZL")
    KZL->(dbGoTop()) 
   
Return .T.   

/*##########################################################
#                 ___  "  ___                              #
#               ( ___ \|/ ___ ) Kazoolo                    #
#                ( __ /|\ __ )  Codefacttory               #
############################################################
#  Função :    # FExec                                     # 
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
Static Function FExec(cl1Tab, cl2Tab, nlUsado, nlReg, alCpoEnch, alVirtual, nlOrder)                   
	Local aArea      := GetArea()
	Local nlPos		 := 0
	
	If !INCLUI  
		If !ALTERA 
	   		FDelKzM3(cl1Tab,cl2Tab, nlReg)  				
		Else
			FAltKzM3(cl1Tab,cl2Tab, nlReg, alCpoEnch, alVirtual, nlUsado)
		EndIf
	Else		
		FGrvKzM3(cl1Tab,cl2Tab, alCpoEnch, alVirtual, nlUsado, nlOrder)
	EndIf
	RestArea(aArea)   
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
Static Function FGrvKzM3(cl1Tab,cl2Tab, alCpoEnch, alVirtual, nlUsado )       
    
	Local nlG		:= 0  
	Local nlI       := 0             
	Local nlCont    := 0                 
	Local c11Fil    := FSelCpoFil(cl1Tab)     
	Local cl2Fil    := FSelCpoFil(cl2Tab)    
	Local clFilial  := xFilial(cl1Tab)       
	    
	
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
	
 	dbSelectArea(cl2Tab)        
	For nlI:=1 to Len(aCols)
		If !aCols[nlI,nlUsado+1] 
			If RecLock(cl2Tab,INCLUI) 
			    Replace &(cl2Tab+"->"+cl2Fil) With clFilial
			  	For nlG:=1 to Len(aHeader)  
			  		If aHeader[nlG,10] <> "V"
			  			FieldPut(FieldPos(aHeader[nlG][2]),aCols[nlI][nlG])	 
			  		EndIf		                             
				Next nlG	                                 
				For nlCont:=1 to Len(aKzM3GrvR) 
					Replace &(aKzM3GrvR[nlCont,2]) With &(aKzM3GrvR[nlCont,1])			
				Next nlCont 
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
#  Função :    # FAltKzM3                                 # 
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
Static Function FAltKzM3(cl1Tab,cl2Tab, nlRegAlt, alCampos, alVirtual, nlUsado)  

	Local nlI 		:= 0  
	local nlC		:= 0    
	Local nlRegPos 	:= 0    
	Local nlCont    := 0
	Local clVar     := "" 
	Local clFilCpo  := ""        
	Local c11Fil    := FSelCpoFil(cl1Tab)
	Local cl2Fil    := FSelCpoFil(cl2Tab)
	Local clFilial  := xFilial(cl1Tab)
                                                    
	If ( (nlRegPos:=Ascan(aHeader,{|x|"_REC_WT"$Alltrim(X[2])}))>0)     
		BEGIN TRANSACTION     
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
		END TRANSACTION 
	EndIf  

Return Nil                                                   

/*##########################################################
#                 ___  "  ___                              #
#               ( ___ \|/ ___ ) Kazoolo                    #
#                ( __ /|\ __ )  Codefacttory               #
############################################################
#  Função :    # FSelCpoFil                                 # 
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
Static Function FSelCpoFil(clAlias)
    
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
#  Função :    # FDelKzM3                                 # 
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
Static Function FDelKzM3(cl1Tab,cl2Tab, nlRegDel)

	Local nlRegPos   := 0
	Local nlC        := 0  

	If ( (nlRegPos:=Ascan(aHeader,{|x|"_REC_WT"$Alltrim(X[2])}))>0)  
		BEGIN TRANSACTION
			dbSelectArea(cl1Tab) 
			&(cl1Tab)->(dbGotop())
			&(cl1Tab)->(dbGoTo(nlRegDel))            
			If RecLock(cl1Tab,INCLUI)
				&(cl1Tab)->(dbDelete())
				&(cl1Tab)->(MsUnLock()) 	
			EndIf  
			&(cl1Tab)->(dbCloseArea())
					
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
			    
		END TRANSACTION
	Endif      
		
Return Nil                       


/*##########################################################
#                 ___  "  ___                              #
#               ( ___ \|/ ___ ) Kazoolo                    #
#                ( __ /|\ __ )  Codefacttory               #
############################################################
#  Função :    # FGetTitleAlias                            # 
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
Static Function FGetTitleAlias(clTabela)     

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
#  Função :    # AM103Val                                      # 
############################################################
# Retorno :    # llAux :                                   #
############################################################
# Descrição :  # VALIDAÇÃO PARA PREENCHIMENTO CORRETO DOS CAMPOS#
#              # ARMAZEM, LOJA E CODIGO DE TABELA          #
#              #                                           #
############################################################
# Autor :      # Cleber Cintra Barbosa                     #
############################################################
# Data :       #  12/05/10                                 #
############################################################
# Palavras Chaves :  #                                     #
##########################################################*/

Function AM103Val()

	Local llAux := .T.
  	
	If !empty(M->EWE_LOJARM) .AND. !empty(M->EWE_CODARM)    
	    DbSelectArea("EWE")
	    DbSetOrder(1)
	 	If DbSeek(xfilial("EWE")+ M->EWE_CODARM + M->EWE_LOJARM +M->EWE_CODTAB)
			llAux:= .F.
			Help(" ",1,"JAGRAVADO")
		Endif
	Else 
		Aviso(STR0007,STR0008,{STR0009 })
	Endif

Return(llAux) 

/*##########################################################
#                 ___  "  ___                              #
#               ( ___ \|/ ___ ) Kazoolo                    #
#                ( __ /|\ __ )  Codefacttory               #
############################################################
#  Função :    # AM100VLD()                                    # 
############################################################
# Retorno :    # .T. or .F.                                #
############################################################
# Descrição :  # VERIFICAÇÃO PARA CAMPOS OBRIGATORIOS DO GETDADOS#
#              # E VALORES INCORRETOS NOS CAMPOS NUMERICOS #
############################################################
# Autor :      # Cleber Cintra Barbosa                     #
############################################################
# Data :       #  12/05/10                                 #
############################################################
# Palavras Chaves :  #                                     #
##########################################################*/

Static Function AM100VLD()
		
    If empty(aCols[n][ aScan(aHeader,{|x| AllTrim(X[2])== "EWF_CODSRV"})])
    	Aviso(STR0007,STR0010,{STR0009})
    	Return .F.
    ElseIf empty(aCols[n][ aScan(aHeader,{|x| AllTrim(X[2])== "EWF_PERIOD"})])
    	Aviso(STR0007,STR0011,{STR0009})
    	Return .F.                                                            
    ElseIf aCols[n][ aScan(aHeader,{|x| AllTrim(X[2])== "EWF_ALISS"})] < 0
    	Aviso(STR0007,STR0012,{STR0009})
    	Return .F.
    ElseIf aCols[n][ aScan(aHeader,{|x| AllTrim(X[2])== "EWF_PRCTOT"})] < 0
    	Aviso(STR0007,STR0013,{STR0009})
    	Return .F.
    Endif

Return .T.
Static Function AM100DEL()
	Local alArea  := GetArea()
	Local llRet   := .T.
	Local clSql   := ""
	Local clAlias := GetNextAlias()

	clSql := "SELECT EWG_FILIAL FROM "+RetSqlName("EWG")
	clSql += " WHERE D_E_L_E_T_ = ' '"
	clSql += " AND   EWG_FILIAL = '"+xFilial("EWG")+"'"
	clSql += " AND   EWG_CODTAB = '"+EWE->EWE_CODTAB+"'"

	clAlias := GetNextAlias()
	dbUseArea(.T., "TOPCONN", TCGenQry(,,clSql),clAlias, .T., .T.)
	dbSelectArea(clAlias)
	
	if (clAlias)->(!eof())
		llRet := .F.
	Endif
	(clAlias)->(dbCloseArea())

	RestArea(alArea)
Return llRet

/*
Função    : ContaCols()  
Objetivos : Valida se existe ao menos um registro não deletado na GetDados
Parametros: -
Retorno   : -
Autor     : Flavio Danilo Ricardo - FDR
Revisão   : 
Data      : 24/05/11
*/   
Static Function ContaCols()
Local lRet := .F.
Local i := 1

For i := 1 To Len(aCols)
    If !aCols[i][len(aCols[i])] //esta deletado
       lRet := .T.
       Exit
    EndIf
Next

If !lRet
   MsgInfo("Campos obrigatórios não foram preenchidos!")
ENdIf

Return lRet
