#INCLUDE "loca031.ch"  
/*/{PROTHEUS.DOC} LOCA031.PRW
ITUP BUSINESS - TOTVS RENTAL
CADASTRAMENTO DE ETAPAS
@TYPE FUNCTION
@AUTHOR FRANK ZWARG FUGA
@SINCE 03/12/2020
@VERSION P12
@HISTORY 03/12/2020, FRANK ZWARG FUGA, FONTE PRODUTIZADO.
/*/

#INCLUDE "PROTHEUS.CH"                                                                                                                     
#INCLUDE "RWMAKE.CH"

#DEFINE MAXGETDAD 99999

FUNCTION LOCA031()
LOCA03102()

RETURN(.T.)



/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���PROGRAMA  � LOCC002A  � AUTOR � IT UP BUSINESS     � DATA � 30/06/2007 ���
�������������������������������������������������������������������������͹��
���DESCRICAO � CADASTRAMENTO DE ETAPAS                                    ���
���          � CHAMADA: LOCC001 - MENU: "ALTERAR"                         ���
�������������������������������������������������������������������������͹��
���USO       � ESPECIFICO GPO                                             ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
FUNCTION LOCA03101() 

LOCA03102() 

RETURN(.T.) 



// ======================================================================= \\
FUNCTION LOCA03102() 
// ======================================================================= \\ 
// --> CHAMADA: LOCC001 

LOCAL LRET := .F. 

PRIVATE ODLGETA

PRIVATE CORIGEM := CRIAVAR("FP3_ORIGEM")
PRIVATE CMUNORI := CRIAVAR("FP3_MUNORI")
PRIVATE CESTORI := CRIAVAR("FP3_ESTORI")
PRIVATE CDESTIN := CRIAVAR("FP3_DESTIN")
PRIVATE CROTA   := CRIAVAR("FP3_ROTA"  )
PRIVATE CNOMROT := CRIAVAR("FP3_NOMROT")

CMUNORI := POSICIONE("FP2",1,XFILIAL("FP2") + CORIGEM , "FP2_DESCRI" )
CESTORI := POSICIONE("FP2",1,XFILIAL("FP2") + CORIGEM , "FP2_ESTADO" )
CMUNDES := POSICIONE("FP2",1,XFILIAL("FP2") + CDESTIN , "FP2_DESCRI" )
CESTDES := POSICIONE("FP2",1,XFILIAL("FP2") + CDESTIN , "FP2_ESTADO" )

DEFINE FONT OFONT NAME "ARIAL" SIZE 0,-11 BOLD  

IF TYPE("JORIGEM")=="C" .AND. TYPE("JDESTIN")=="C"
	CORIGEM := JORIGEM
	CDESTIN := JDESTIN
	CROTA   := JROTA
	CNOMROT := JNOMROT
	CMUNORI := POSICIONE("FP2",1,XFILIAL("FP2") + CORIGEM , "FP2_DESCRI" )
	CESTORI := POSICIONE("FP2",1,XFILIAL("FP2") + CORIGEM , "FP2_ESTADO" )
	CMUNDES := POSICIONE("FP2",1,XFILIAL("FP2") + CDESTIN , "FP2_DESCRI" )
	CESTDES := POSICIONE("FP2",1,XFILIAL("FP2") + CDESTIN , "FP2_ESTADO" )
	IF EMPTY(CROTA)
		FP3->(DBSEEK(XFILIAL("FP3")+CORIGEM+CDESTIN))
		WHILE FP3->(!EOF() .AND. FP3_FILIAL+FP3_ORIGEM+FP3_DESTIN==XFILIAL("FP3")+CORIGEM+CDESTIN)
			CROTA   := FP3->FP3_ROTA
			CNOMROT := FP3->FP3_NOMROT
			FP3->(DBSKIP())
		ENDDO 
		CROTA   := STRZERO(VAL(CROTA)+1,LEN(CROTA))
		CNOMROT := SPACE(LEN(CNOMROT))
	ENDIF
ENDIF

DEFINE MSDIALOG OTELA TITLE STR0001 FROM 000,000 TO 550,758 PIXEL //"CADASTRAMENTO DE ROTAS"

NLIN1 := 018
NCOL1 := 005
NLIN2 := 060
NCOL2 := 375
NPULA := 011
 
@ NLIN1,NCOL1 TO NLIN1+18+NPULA+NPULA,NCOL2 OF OTELA PIXEL
@ NLIN1+06,NCOL1+005 SAY OEMTOANSI(STR0002) SIZE 060,008 OF OTELA PIXEL //"ORIGEM:"
@ NLIN1+05,NCOL1+030 MSGET OORIGEM VAR CORIGEM PICTURE "@!" SIZE 030,008 OF OTELA PIXEL WHEN UPPER(ALLTRIM(SUBS(CUSUARIO,7,05)))==UPPER("ADMIN") VALID(FVER002("CORIGEM")) F3 "ZA2B"
@ NLIN1+05,NCOL1+067 MSGET OMUNORI VAR CMUNORI PICTURE "@!" SIZE 150,008 OF OTELA PIXEL WHEN .F.
@ NLIN1+05,NCOL1+220 MSGET OESTORI VAR CESTORI PICTURE "@!" SIZE 010,008 OF OTELA PIXEL WHEN .F.

@ NLIN1+06+NPULA,NCOL1+005 SAY OEMTOANSI(STR0003) SIZE 060,008 OF OTELA PIXEL //"DESTINO:"
@ NLIN1+05+NPULA,NCOL1+030 MSGET ODESTIN VAR CDESTIN PICTURE "@!" SIZE 030,008 OF OTELA PIXEL WHEN UPPER(ALLTRIM(SUBS(CUSUARIO,7,05)))==UPPER("ADMIN") VALID(FVER002("CDESTIN")) F3 "ZA2B"
@ NLIN1+05+NPULA,NCOL1+067 MSGET OMUNDES VAR CMUNDES PICTURE "@!" SIZE 150,008 OF OTELA PIXEL WHEN .F.
@ NLIN1+05+NPULA,NCOL1+220 MSGET OESTDES VAR CESTDES PICTURE "@!" SIZE 010,008 OF OTELA PIXEL WHEN .F.

@ NLIN1+06+NPULA+NPULA,NCOL1+005 SAY OEMTOANSI(STR0004) SIZE 030,008 OF OTELA PIXEL //"ROTA:"
@ NLIN1+05+NPULA+NPULA,NCOL1+030 MSGET OROTA   VAR CROTA   PICTURE "@!" SIZE 015,008 OF OTELA PIXEL /*WHEN UPPER(ALLTRIM(SUBS(CUSUARIO,7,05)))==UPPER("ADMIN")*/ VALID(FVER002("CROTA"))
@ NLIN1+05+NPULA+NPULA,NCOL1+067 MSGET ONOMROT VAR CNOMROT PICTURE "@X" SIZE 150,008 OF OTELA PIXEL /*WHEN UPPER(ALLTRIM(SUBS(CUSUARIO,7,05)))==UPPER("ADMIN")*/ VALID(FVER002("CNOMROT"))

FFOLDERETA(0,NLIN1+05+NPULA+NPULA+18,NCOL1,245,NCOL2)

ACTIVATE MSDIALOG OTELA CENTERED ON INIT ENCHOICEBAR(OTELA,{||IIF(LOCA03104(), (LRET:=.T.,FATUETAPAS(),OTELA:END()),LRET:=.F.) },{||LRET:=.F.,OTELA:END() }) 
  
RETURN(LRET)



// ======================================================================= \\
STATIC FUNCTION FFOLDERETA(NFOLDER,NLIN1,NCOL1,NLIN2,NCOL2)
// ======================================================================= \\

LOCAL ACAMPOSSIM := {}
LOCAL NSTYLE     := GD_INSERT + GD_UPDATE + GD_DELETE

LOCAL CALIAS , CCHAVE , CCONDICAO , NINDICE , CFILTRO 

CALIAS    := "FP3"
CCHAVE    := XFILIAL(CALIAS)+CORIGEM+CDESTIN+CROTA
CCONDICAO := 'FP3_FILIAL+FP3_ORIGEM+FP3_DESTIN+FP3_ROTA=="'+CCHAVE+'"'
NINDICE   := 1  		// FP3_FILIAL+FP3_ORIGEM+FP3_DESTIN+FP3_ROTA+FP3_ETAPA
CFILTRO   := CCONDICAO

// GETDADOS
AADD(ACAMPOSSIM,{"FP3_ETAPA" ,""})
AADD(ACAMPOSSIM,{"FP3_DE"    ,""})
AADD(ACAMPOSSIM,{"FP3_MUNDE" ,""})
AADD(ACAMPOSSIM,{"FP3_ESTDE" ,""})
AADD(ACAMPOSSIM,{"FP3_ATE"   ,""})
AADD(ACAMPOSSIM,{"FP3_MUNATE",""})
AADD(ACAMPOSSIM,{"FP3_ESTATE",""})
AADD(ACAMPOSSIM,{"FP3_DISTAN",""})
AADD(ACAMPOSSIM,{"FP3_VAZIO" ,""}) 
AADD(ACAMPOSSIM,{"FP3_RODOVI",""})
AADD(ACAMPOSSIM,{"FP3_QTDPED",""})
AADD(ACAMPOSSIM,{"FP3_VREIXO",""})
AADD(ACAMPOSSIM,{"FP3_TIPORO",""})
AADD(ACAMPOSSIM,{"FP3_TIPOPI",""})
AADD(ACAMPOSSIM,{"FP3_TRANSU",""})
//DD(ACAMPOSSIM,{"FP3_TEMTUR",""})
AADD(ACAMPOSSIM,{"FP3_TEMALE",""})
AADD(ACAMPOSSIM,{"FP3_TEMBLO",""})
//DD(ACAMPOSSIM,{"FP3_FATTAP",""})
AADD(ACAMPOSSIM,{"FP3_OBS"   ,""})

AHEADER := FHEADER(ACAMPOSSIM)
ACOLS   := FCOLS(AHEADER,CALIAS,NINDICE,CCHAVE,CCONDICAO,CFILTRO)

IF LEN(ACOLS)==1
	CCAMPO    := "FP3_ETAPA"
	CCAMPOGET := ACOLS[1][ASCAN(AHEADER,{|X|ALLTRIM(X[2])==CCAMPO})]
	ACOLS[1][ASCAN(AHEADER,{|X|ALLTRIM(X[2])==CCAMPO})]:=STRZERO(1,LEN(CCAMPOGET))
ENDIF

//                             NTOP ,NLEFT,NBOTTOM,NRIGHT,NSTYLE,CLINHAOK,CTUDOOK      ,CINICPOS    ,AALTER,NFREEZE,NMAX,CFIELDOK,CSUPERDEL,CDELOK,OWND ,AHEADER,ACOLS 
ODLGETA := MSNEWGETDADOS():NEW(NLIN1,NCOL1,NLIN2  ,NCOL2 ,NSTYLE,        ,"LOCA03104","+FP3_ETAPA",      ,       ,110 ,        ,         ,.T.   ,OTELA,AHEADER,ACOLS) 
ODLGETA:OBROWSE:BCHANGE := {||LOCA03103()} 

//@ NLIN2+005,INT((NCOL2-NCOL1)/2)-30 BUTTON OBUTTETA PROMPT "ATUALIZA" SIZE 60,10 ACTION FATUETAPAS() OF OFOLDER:ADIALOGS[NFOLDER] PIXEL

RETURN



// ======================================================================= \\
FUNCTION LOCA03103() 		// MUDA O BROWSE
// ======================================================================= \\

LOCAL LRET := .T.

IF VALTYPE(ODLGETA)=="O"  		// SE O OBJETO J� FOI CRIADO
	IF LEN(ODLGETA:ACOLS)>1 .AND. LEN(ODLGETA:ACOLS)==ODLGETA:NAT
		CATEE    := ODLGETA:ACOLS[LEN(ODLGETA:ACOLS)-1][ASCAN(ODLGETA:AHEADER,{|X|ALLTRIM(X[2])=="FP3_ATE"})]
		CMUNATEE := ODLGETA:ACOLS[LEN(ODLGETA:ACOLS)-1][ASCAN(ODLGETA:AHEADER,{|X|ALLTRIM(X[2])=="FP3_MUNATE"})]
		CESTATEE := ODLGETA:ACOLS[LEN(ODLGETA:ACOLS)-1][ASCAN(ODLGETA:AHEADER,{|X|ALLTRIM(X[2])=="FP3_ESTATE"})]
		ODLGETA:ACOLS[ODLGETA:NAT][ASCAN(ODLGETA:AHEADER,{|X|ALLTRIM(X[2])=="FP3_DE"   })] := CATEE 
		ODLGETA:ACOLS[ODLGETA:NAT][ASCAN(ODLGETA:AHEADER,{|X|ALLTRIM(X[2])=="FP3_MUNDE"})] := CMUNATEE 
		ODLGETA:ACOLS[ODLGETA:NAT][ASCAN(ODLGETA:AHEADER,{|X|ALLTRIM(X[2])=="FP3_ESTDE"})] := CESTATEE 
	ENDIF 
	ODLGETA:OBROWSE:REFRESH() 
ENDIF 

RETURN LRET 



// ======================================================================= \\
STATIC FUNCTION FHEADER(ACAMPOSSIM)
// ======================================================================= \\

LOCAL NPOS , ATABAUX , AHEADER := {}

DBSELECTAREA("SX3")
DBSETORDER(2)  					// X3_CAMPO
FOR NPOS:=1 TO LEN(ACAMPOSSIM)
	IF SX3->(DBSEEK(ALLTRIM(ACAMPOSSIM[NPOS,1])))
		ATABAUX := {}
		AADD(ATABAUX     , TRIM(X3TITULO()))
		AADD(ATABAUX     , GetSx3Cache(&(LOCXCONV(2)),"X3_CAMPO")        )    
		AADD(ATABAUX     , GetSx3Cache(&(LOCXCONV(2)),"X3_PICTURE")      )    
		AADD(ATABAUX     , GetSx3Cache(&(LOCXCONV(2)),"X3_TAMANHO")      )    
		AADD(ATABAUX     , GetSx3Cache(&(LOCXCONV(2)),"X3_DECIMAL")      )    
		AADD(ATABAUX     , GetSx3Cache(&(LOCXCONV(2)),"X3_VALID")        )    
		AADD(ATABAUX     , GetSx3Cache(&(LOCXCONV(2)),"X3_USADO")        )    
		AADD(ATABAUX     , GetSx3Cache(&(LOCXCONV(2)),"X3_TIPO")         )    
		AADD(ATABAUX     , GetSx3Cache(&(LOCXCONV(2)),"X3_F3")           )    
		AADD(ATABAUX     , GetSx3Cache(&(LOCXCONV(2)),"X3_CONTEXT")      )    
		AADD(ATABAUX     , GetSx3Cache(&(LOCXCONV(2)),"X3_CBOX")         )    
		AADD(ATABAUX     , GetSx3Cache(&(LOCXCONV(2)),"X3_RELACAO")      )    
		AADD(ATABAUX     , GetSx3Cache(&(LOCXCONV(2)),"X3_WHEN")         )    
		IF !EMPTY(ACAMPOSSIM[NPOS,2])
			AADD(ATABAUX , ACAMPOSSIM[NPOS,2])
		ELSE
			AADD(ATABAUX , GetSx3Cache(&(LOCXCONV(2)),"X3_VISUAL")       )    
		ENDIF
		IF EMPTY(ALLTRIM(GetSx3Cache(&(LOCXCONV(2)),"X3_VLDUSER")))           
			AADD(ATABAUX , "LOCA00147('"+UPPER(ALLTRIM(GetSx3Cache(&(LOCXCONV(2)),"X3_CAMPO")))+"')")       
		ELSE
			AADD(ATABAUX , GetSx3Cache(&(LOCXCONV(2)),"X3_VLDUSER")      )    
		ENDIF
		AADD(ATABAUX     , GetSx3Cache(&(LOCXCONV(2)),"X3_PICTVAR")      )    
		AADD(ATABAUX     , GetSx3Cache(&(LOCXCONV(2)),"X3_OBRIGAT")      )    
		AADD(AHEADER     , ATABAUX         )  
	ENDIF
NEXT

DBSETORDER(1)  					// X3_ARQUIVO + X3_ORDEM 

RETURN(ACLONE(AHEADER))



// ======================================================================= \\
STATIC FUNCTION FCOLS(AHEADER,CALIAS,NINDICE,CCHAVE,CCONDICAO,CFILTRO)
// ======================================================================= \\

LOCAL NPOS,ACOLS0,ACOLS:={}
LOCAL CALIASANT:=ALIAS()

DBSELECTAREA(CALIAS)

(CALIAS)->(DBSETORDER(NINDICE))
(CALIAS)->(DBSEEK(CCHAVE,.T.))
WHILE (CALIAS)->(!EOF() .AND. &CCONDICAO)
	IF !(CALIAS)->(&CFILTRO)
		(CALIAS)->(DBSKIP())
        LOOP
	ENDIF
	ACOLS0:={}
	FOR NPOS:=1 TO LEN(AHEADER)
		IF !AHEADER[NPOS,10]=="V"  //X3_CONTEXT
			(CALIAS)->(AADD(ACOLS0,FIELDGET(FIELDPOS(AHEADER[NPOS,2]))))
		ELSE
			(CALIAS)->(AADD(ACOLS0,CRIAVAR(AHEADER[NPOS,2])))
		ENDIF
	NEXT
	AADD(ACOLS0 , .F.) 			// DELETED
	AADD(ACOLS,ACOLS0)
	(CALIAS)->(DBSKIP())
ENDDO 

IF EMPTY(ACOLS)
	ACOLS0:={}
	FOR NPOS:=1 TO LEN(AHEADER)
		(CALIAS)->(AADD(ACOLS0,CRIAVAR(AHEADER[NPOS,2])))
	NEXT
	AADD(ACOLS0 , .F.) 			// DELETED
	AADD(ACOLS,ACOLS0)
ENDIF

ACOLS0:={}
FOR NPOS:=1 TO LEN(AHEADER)
	(CALIAS)->(AADD(ACOLS0,CRIAVAR(AHEADER[NPOS,2])))
NEXT
AADD(ACOLS0 , .F.) 				// DELETED

DBSELECTAREA(CALIASANT)

RETURN(ACLONE(ACOLS))



// ======================================================================= \\
STATIC FUNCTION FATUETAPAS() 
// ======================================================================= \\

IF VALTYPE(ODLGETA)=="O" 	// SE O OBJETO J� FOI CRIADO
	INCPROC(STR0005) //"ATUALIZANDO... ETAPAS"
	FSALVARETA("FP3",ODLGETA:AHEADER,ODLGETA:ACOLS)
ELSE
	MSGSTOP(STR0006 , STR0007)  //"N�O ATUALIZOU ETAPAS !!"###"GPO - LOCC002.PRW"
ENDIF

RETURN



// ======================================================================= \\
STATIC FUNCTION FSALVARETA(CALIAS,AHEADER,ACOLS) 	// ETAPAS
// ======================================================================= \\

LOCAL NPOS,AGRAVADOS := {} 							// GRAVADOS

CMUNORI := POSICIONE("FP2",1,XFILIAL("FP2") + CORIGEM , "FP2_DESCRI" )
CESTORI := POSICIONE("FP2",1,XFILIAL("FP2") + CORIGEM , "FP2_ESTADO" )
CMUNDES := POSICIONE("FP2",1,XFILIAL("FP2") + CDESTIN , "FP2_DESCRI" )
CESTDES := POSICIONE("FP2",1,XFILIAL("FP2") + CDESTIN , "FP2_ESTADO" )

DBSELECTAREA(CALIAS)
DBSETORDER(1) 				// FP3_FILIAL+FP3_ORIGEM+FP3_DESTIN+FP3_ROTA+FP3_ETAPA

IF NOPC==5  				// 5=EXCLUI
ELSE
	FOR NPOS:=1 TO LEN(ACOLS)
		CETAPA :=ACOLS[NPOS][ASCAN(AHEADER,{|X|ALLTRIM(X[2])=="FP3_ETAPA" })]
		CDE    :=ACOLS[NPOS][ASCAN(AHEADER,{|X|ALLTRIM(X[2])=="FP3_DE"    })]
		CATE   :=ACOLS[NPOS][ASCAN(AHEADER,{|X|ALLTRIM(X[2])=="FP3_ATE"   })]
		IF !ACOLS[NPOS,LEN(AHEADER)+1] .AND. !EMPTY(CORIGEM+CDESTIN) .AND. !EMPTY(CROTA+CETAPA) .AND. !EMPTY(CDE+CATE)  //!DELETED()
			DBSEEK(XFILIAL(CALIAS)+CORIGEM+CDESTIN+CROTA+CETAPA)
			IF EOF()
				RECLOCK(CALIAS,.T.)
			ELSE
				RECLOCK(CALIAS,.F.)
			ENDIF
			FGRAVATUDO(CALIAS,AHEADER,ACOLS[NPOS]) 	// GRAVA TODOS OS CAMPOS DO ACOLS
			(CALIAS)->FP3_FILIAL:=XFILIAL(CALIAS)
			(CALIAS)->FP3_ORIGEM:=CORIGEM
			(CALIAS)->FP3_DESTIN:=CDESTIN
			(CALIAS)->FP3_ROTA  :=CROTA
			(CALIAS)->FP3_NOMROT:=CNOMROT
			(CALIAS)->FP3_ETAPA :=CETAPA
			(CALIAS)->FP3_DE    :=CDE
			(CALIAS)->FP3_ATE   :=CATE
			(CALIAS)->FP3_MUNORI:=CMUNORI
			(CALIAS)->FP3_ESTORI:=CESTORI
			(CALIAS)->FP3_MUNDES:=CMUNDES
			(CALIAS)->FP3_ESTDES:=CESTDES
			AADD(AGRAVADOS,RECNO())  //GRAVADOS
			MSUNLOCK()
	     ENDIF
	NEXT
ENDIF

// EXCLUI OS REGISTROS ALTERADOS
DBSEEK(XFILIAL(CALIAS)+CORIGEM+CDESTIN+CROTA)
WHILE !EOF() .AND. FP3_FILIAL+FP3_ORIGEM+FP3_DESTIN+FP3_ROTA==XFILIAL(CALIAS)+CORIGEM+CDESTIN+CROTA
	IF ASCAN(AGRAVADOS,{|X|X==RECNO()})==0
		RECLOCK(CALIAS,.F.)
		DBDELETE()
		MSUNLOCK()
	ENDIF
	DBSKIP()
ENDDO 

RETURN



// ======================================================================= \\
STATIC FUNCTION FGRAVATUDO(CALIAS,AHEADER,ACOLS) 	// GRAVA TODOS OS CAMPOS DO ACOLS
// ======================================================================= \\

LOCAL NPOS , CCAMPO
FOR NPOS:=1 TO LEN(AHEADER)
	CCAMPO := AHEADER[NPOS,2]
	(CALIAS)->(&CCAMPO):=ACOLS[NPOS]
NEXT

RETURN(.T.)



// ======================================================================= \\
STATIC FUNCTION FVER002(CVAR)
// ======================================================================= \\

DO CASE
CASE UPPER(CVAR)==UPPER("CORIGEM")
	CMUNORI := POSICIONE("FP2",1,XFILIAL("FP2") + CORIGEM , "FP2_DESCRI" )
	CESTORI := POSICIONE("FP2",1,XFILIAL("FP2") + CORIGEM , "FP2_ESTADO" )
CASE UPPER(CVAR)==UPPER("CDESTIN")
	CMUNDES := POSICIONE("FP2",1,XFILIAL("FP2") + CDESTIN , "FP2_DESCRI" )
	CESTDES := POSICIONE("FP2",1,XFILIAL("FP2") + CDESTIN , "FP2_ESTADO" )
CASE UPPER(CVAR)==UPPER("CROTA")
	FFOLDERETA(0,NLIN1+05+NPULA+NPULA+18,NCOL1,245,NCOL2)
	ODLGETA:OBROWSE:REFRESH()
ENDCASE

RETURN(.T.)



// ======================================================================= \\
FUNCTION LOCA03104()
// ======================================================================= \\

LOCAL LRET := .T.
LOCAL NX   := 0 
        
FOR NX := 1 TO LEN(ODLGETA:ACOLS)
	IF EMPTY(ODLGETA:ACOLS[NX][ASCAN(ODLGETA:AHEADER,{|X|ALLTRIM(X[2])=="FP3_VAZIO"})])
		MSGALERT(STR0008 , STR0007)  //"ATEN��O: O CAMPO VAZIO/CARREG DEVE SER PREENCHIDO"###"GPO - LOCC002.PRW"
		LRET := .F. 
		EXIT 
	ENDIF 
NEXT NX 
	
RETURN(LRET) 
