#include "PLSMGER.CH"
#include "PROTHEUS.CH"
#include "COLORS.CH"
#IFDEF TOP
       #include "TOPCONN.CH"
#ENDIF       

Static lPLSUNI := GetNewPar("MV_PLSUNI", "0") == "1"

/*/
苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北�
北谀哪哪哪哪穆哪哪哪哪穆哪哪哪穆哪哪哪哪哪哪哪哪哪哪哪履哪哪穆哪哪哪哪哪哪勘�
北砅rograma  � PLSA588 � Autor � Daher		          � Data � 20.01.2007 潮�
北媚哪哪哪哪呐哪哪哪哪牧哪哪哪牧哪哪哪哪哪哪哪哪哪哪哪聊哪哪牧哪哪哪哪哪哪幢�
北矰escri噭o � Pacotes x Classe RDA                                       潮�
北媚哪哪哪哪呐哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪幢�
北砋so       � Advanced Protheus                                          潮�
北媚哪哪哪哪呐哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪幢�
北砅arametros� Nenhum                                                     潮�
北媚哪哪哪哪牧哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪幢�
北�            ATUALIZACOES SOFRIDAS DESDE A CONSTRU�AO INICIAL           潮�
北媚哪哪哪哪哪穆哪哪哪哪履哪哪穆哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪幢�
北砅rogramador � Data   � BOPS �  Motivo da Altera噭o                     潮�
北媚哪哪哪哪哪呐哪哪哪哪拍哪哪呐哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪幢�
北滥哪哪哪哪哪牧哪哪哪哪聊哪哪牧哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪俦�
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北�
哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌�
/*/
Function PLSA588
LOCAL aAliasItem:= {}
LOCAL aChavCab  := {}
LOCAL aCondItem := {}
LOCAL aKeyItem  := {}
LOCAL nI		:= 1                  
LOCAL aOrdens   := {}
LOCAL aCBox		:= {}
PRIVATE aBox 		:= {}
PRIVATE aCols   := {}
PRIVATE aHeader := {}
PRIVATE nIniPad	:= 0

If ! lPLSUNI
    PL586CarCr()

    aCBox := RetSx3Box(X3CBox(Posicione('SX3' , 2 ,"BR8_TPPROC",'X3_CBOX')	),,,1)

    For nI := 1 to Len(aCBox)
        If !Empty(aCBox[nI][1]) .and. aCBox[nI][2] <> '6'
            aadd(aAliasItem,{"B42",aCBox[nI][3],,})
            aadd(aKeyItem  ,"B41->(B41_CODINT+B41_TIPPRE+B41_CODPAD+B41_CODPRO)+'"+aCBox[nI][2]+"'")
            aadd(aCondItem ,"B42->(B42_CODINT+B42_TIPPRE+B42_CODPAD+B42_CODPRO+B42_TIPO)")
            aadd(aChavCab  ,{{"B42_CODINT","M->B41_CODINT"},{"B42_TIPPRE","M->B41_TIPPRE"},{"B42_CODPAD","M->B41_CODPAD"},{"B42_CODPRO","M->B41_CODPRO"},{"B42_TIPO","'"+aCBox[nI][2]+"'"}})
            aadd(aOrdens,1)
            aadd(aBox,aCBox[nI])
        Endif
    Next

    PlsCabItem("B41","Classe R.D.A X Pacotes",aAliasItem,aOrdens,aKeyItem,aCondItem,aChavCab)
Else
    MsgAlert("Devido o PTU A1200, essa rotina n鉶 est� mais dispon韛el para cliente UNIMED.")
EndIf 


Return

/*                   
苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘�
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北�
北谀哪哪哪哪穆哪哪哪哪哪哪履哪哪哪履哪哪哪哪哪哪哪哪哪哪履哪哪穆哪哪哪哪哪勘�
北矲uncao    � Pl588Valid � Autor � Daher				� Data � 02.07.03 潮�
北媚哪哪哪哪呐哪哪哪哪哪哪聊哪哪哪聊哪哪哪哪哪哪哪哪哪哪聊哪哪牧哪哪哪哪哪幢�
北矰escricao � Validacao de campos do pacote							  潮�
北滥哪哪哪哪牧哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪俦�
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北�
哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌�
/*/
Function Pl588Valid()
LOCAL lRet 		:= .T.
LOCAL nJ   		:= 1
Local sJ        := 0
LOCAL nI        := 1         
LOCAL cReadVar  := alltrim(ReadVar())
LOCAL cChave	:= ""
LOCAL aFirst	:= {.T.,.T.,.T.,.T.,.T.,.T.,.T.,.T.,.T.}


If cReadVar == "M->B42_PRINCI"
		cChave := M->(B42_CPADOC+B42_CODOPC)
		For nJ := 1 to Len(aObjGd)
			For nI := 1 to Len(aObjGd[nJ]:aCols)
				If aObjGd[nJ]:aCols[nI][aObjGd[nJ]:FieldPos("B42_ATIVO")]  == '1' .and. ;
				   aObjGd[nJ]:aCols[nI][aObjGd[nJ]:FieldPos("B42_PRINCI")] == '1' .and. ;
				   aObjGd[nJ]:aCols[nI][aObjGd[nJ]:FieldPos("B42_CPADOC")]+aObjGd[nJ]:aCols[nI][aObjGd[nJ]:FieldPos("B42_CODOPC")] <> cChave .and. ;
				   M->B42_PRINCI == '1'

					lRet := .F.
					Exit

				Endif
			Next 
		Next
		If !lRet
			Help("",1,"PLSA586001")
		Endif
Endif
                
If cReadVar == "M->B41_CODPAD"
	lRet := B41->(ExistChav("B41",M->(B41_CODINT+B41_TIPPRE+B41_CODPAD+B41_CODPRO),1))
Endif                        

If cReadVar == "M->B42_VIGATE"
	lRet := Empty(M->B42_VIGATE) .or. M->B42_VIGATE >= M->B42_VIGDE
	If !lRet
		Help("",1,"PLSA586002")
	Endif
Endif                        

If cReadVar == "M->B42_VIGDE"
	lRet := (Empty(M->B42_VIGDE) .and. !Empty(M->B42_VIGATE)) .or. M->B42_VIGATE >= M->B42_VIGDE .or. (!Empty(M->B42_VIGDE) .and. Empty(M->B42_VIGATE))
	If !lRet
		Help("",1,"PLSA586002")
	Endif
Endif                        

If cReadVar == "M->B41_CODPRO" .Or. cReadVar == "M->B41_CODPAD" 
	lRet := B41->(ExistChav("B41",M->(B41_CODINT+B41_TIPPRE+B41_CODPAD+B41_CODPRO),1))
	If lRet
		BLE->(DbSetOrder(1))
		If BLE->(MsSeek(xFilial("BLE")+M->B41_CODINT+M->B41_CODPAD+M->B41_CODPRO))
			For nJ := 1 to Len(aObjGd)                 
					aObjGd[nJ]:aCols := {}                     
					aObjGd[nJ]:AddBlank()                           
			Next     
			While !BLE->(Eof()) .and. xFilial("BLE")+M->B41_CODINT+M->B41_CODPAD+M->B41_CODPRO == BLE->(BLE_FILIAL+BLE_CODINT+BLE_CODPAD+BLE_CODPRO)
		    	If Val(BLE->BLE_TIPO) < 6
		    		nJ := Val(BLE->BLE_TIPO) + 1
		    	Else
		    		nJ := Val(BLE->BLE_TIPO) 
		    	Endif
		    	If !aFirst[nJ]
		    		aObjGd[nJ]:AddBlank()                           
		        Else
		        	aFirst[nJ] := .F.
		        Endif               
		        
			    For nI:=1 to Len(aObjGd[nJ]:aHeader)
		     		cCampo := aObjGd[nJ]:aHeader[nI][2]
			     	If cCampo == "B42_TIPPRE"
			     		aObjGd[nJ]:FieldPut(cCampo , M->B41_TIPPRE , Len(aObjGd[nJ]:aCols))              
			     	ElseIF cCampo == "B42_DESOPC"
			     		aObjGd[nJ]:FieldPut(cCampo, Posicione("BR8",1,xFilial("BR8")+BLE->BLE_CPADOC+BLE->BLE_CODOPC,"BR8_DESCRI") , Len(aObjGd[nJ]:aCols))              
			     	Else
			     		aObjGd[nJ]:FieldPut(cCampo , &('BLE->'+strtran(cCampo,'B42','BLE'))  , Len(aObjGd[nJ]:aCols))              
					Endif
				Next
				BLE->(DbSkip())
			Enddo
			For nJ := 1 to Len(aObjGd)
				If nJ == 7
					sJ := sJ + 1
		    	EndIf
		    	aObjGd[nJ]:acols[1][PLRETPOS("B42_TIPO",aObjGd[nJ]:aHeader)]:= alltrim(STR(sJ))                              
				aObjGd[nJ]:ForceRefresh(aObjGd[nJ])
				sJ++				
			Next
		Else
			For nJ := 1 to Len(aObjGd)
				If nJ == 7
					sJ := sJ + 1
		    	EndIf
		    	aObjGd[nJ]:acols[1][PLRETPOS("B42_TIPO",aObjGd[nJ]:aHeader)]:= alltrim(STR(sJ))                              
				aObjGd[nJ]:ForceRefresh(aObjGd[nJ])
				sJ++				
			Next
		Endif
	Endif
Endif

Return lRet 

//-------------------------------------------------------------------
/*/{Protheus.doc} MenuDef
Funcao para criar o menu da tela
@author Oscar Zanin
@since 08/04/2019
@version P12
/*/
//-------------------------------------------------------------------
Static Function MenuDef()

Local aRotina := PLSMnDefY(, "B41", , )

Return(aRotina)