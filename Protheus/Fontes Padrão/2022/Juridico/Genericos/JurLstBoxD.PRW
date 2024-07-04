#INCLUDE "PROTHEUS.CH"
#INCLUDE "JURLSTBOXD.CH"
#DEFINE anRow 1
#DEFINE anCol 2
#DEFINE anWidth 3
#DEFINE anHeight 4     

/*
anRow  NumÈrico, opcional. Coordenada vertical em pixels ou caracteres.  
anCol  NumÈrico, opcional. Coordenada horizontal em pixels ou caracteres 
anWidth  NumÈrico, opcional. Largura do controle em pixels.  
anHeight  NumÈrico, opcional. Altura do controle em pixels.  
*/

Function __JurLstBoxD() // Function Dummy
ApMsgInfo( 'JurLstBoxD -> Utilizar Classe ao inves da funcao' )
Return NIL

//-------------------------------------------------------------------                                                   
/*/{Protheus.doc} JurLstBoxD            
Classe para montar dois listbox e mover seus valores        

@author Juliana Iwayama Velho / Rodrigo Antonio
@since 09/12/09
@version 1.0
/*/
//-------------------------------------------------------------------  
CLASS JurLstBoxD
 		  
   Data oCmpDisp
   Data oCmpSel   
   Data oGetSearch
   Data oGetRename
   Data oButtonRename
   Data oButtonSearch   
   Data oGetNewConfig   
   Data oCmbConfig
   Data oCmbTabela   
   Data oDlgWin  
   Data lEnableSearch
   Data lEnableRename
   Data lEnableConfig
   Data aPosCmpDisp
   Data aPosCmpSel
   Data aPosGetSearch   
   Data aPosBtnSearch   
   Data aPosGetRename   
   Data aPosBtnRename   
   Data aPosCmbConfig
   Data aPosGetNewConfig 
   Data aPosCmbTabela
   Data aCmpDisp
   Data aCmpSel
   Data aCmbConfig
   Data aCmbTabela
   Data cGetRename
   Data cGetNewConfig
   Data cCmbConfig 
   Data cCmbTabela
   Data cCmbTabApe
   Data lActivate  
   Data bSelect
   Data bRefresh
   Data bSelectTab
   Data bRemove
   Data aRemove
   Data befAdd
   Data nPosSearch
   Data lAllToDisp
   
	METHOD Activate()
	METHOD New() 	
	METHOD AddOne(oObj1,oObj2,aOrigem,aDestino,lAdd,lRem,nQtMemo)                                  
	METHOD AddAll (oObj1,oObj2,aOrigem,aDestino,aAdic,nQtMemo) 
	METHOD ChangeOne (oObj2,aCampos,nPos)   
	METHOD Search (cCampo)
	METHOD PesquisaCampo( oObj,aCampos,cPesq ) 	
	METHOD GetCmpDisp () 
	METHOD SetCmpDisp ( aDados ) 
	METHOD GetCmpSel ()   
	METHOD SetCmpSel ( aDados ) 	
	METHOD OneToSel () 
	METHOD OneToDisp () 
	METHOD AllToSel () 
	METHOD AllToDisp () 
	METHOD DisaDbClic()
	METHOD MoveUp () 
	METHOD MoveDown ()     
	METHOD GetSearch ()
	METHOD GetEnabSch ()
	METHOD SetEnabSch (lValor) 
	METHOD GetPosCmbTabela ()   
	METHOD SetPosCmbTabela ( aPos )   
	METHOD GetPosCmbConfig ()   
	METHOD SetPosCmbConfig ( aPos )   
	METHOD GetPosBtnSearch ()   
	METHOD SetPosBtnSearch ( aPos )   
	METHOD GetPosGetSearch ()   
	METHOD SetPosGetSearch ( aPos )
	METHOD GetPosCmpSel ()        
	METHOD SetPosCmpSel ( aPos )     
	METHOD GetPosCmpDisp ()   
	METHOD SetPosCmpDisp ( aPos )    
	METHOD GetPosBtnRename ()   
	METHOD SetPosBtnRename ( aPos )   
	METHOD GetPosGetRename ()   
	METHOD SetPosGetRename ( aPos )
	METHOD GetPosGetNewConfig ()   
	METHOD SetPosGetNewConfig ( aPos )    
	METHOD GetDlgWin ()      
	METHOD SetDlgWin ()    
	METHOD GetRename ()      
	METHOD SetRename (cValor)    
	METHOD GetEnabRen ()
	METHOD SetEnabRen (lValor)    
	METHOD RefreshRen ()  
	METHOD Rename ()    
	METHOD GetEnabConfig ()
	METHOD SetEnabConfig (lValor)    	  
	METHOD GetTabela ()      
	METHOD SetTabela (cValor)   
	METHOD GetCmbTabela () 
	METHOD SetCmbTabela ( aDados ) 
	METHOD GetConfig ()      
	METHOD SetConfig (cValor)   
	METHOD GetCmbConfig () 
	METHOD SetCmbConfig ( aDados ) 
	METHOD GetNewConfig ()      
	METHOD SetNewConfig (cValor) 
	METHOD RefreshConfig ()      
	METHOD RefreshCmps ()   
	METHOD SetSelect (aDados)      
	METHOD GetSelect ()      
	METHOD SetRefresh (aDados)               
	METHOD SetSelectTab (aDados)      
	METHOD GetSelectTab ()      
	METHOD SetRemove (cValor)      
	METHOD GetRemove ()
	METHOD GetItemsAry(aDados)
	METHOD RefreshDados ()
	METHOD GetaRemove ()
	METHOD SetaRemove (aRemove)   
	METHOD Deactivate()
	METHOD RefreshUsers()
	METHOD SetNSearch(nPos)
    
ENDCLASS               

//-------------------------------------------------------------------                                                   
/*/{Protheus.doc} New            
Inicializa as vari·veis        

@author Juliana Iwayama Velho / Rodrigo Antonio
@since 11/12/09
@version 1.0
/*/
//------------------------------------------------------------------- 
METHOD New()CLASS JurLstBoxD  
	self:lEnableSearch    := .F.
	self:lEnableRename    := .F.
	self:lEnableConfig    := .F.
	self:lActivate        := .F. 
	self:aCmpDisp         := {}
	self:aCmpSel          := {}
    self:aCmbConfig       := {}
    self:aCmbTabela       := {}
    self:aRemove          := {}    
	self:aPosCmpDisp      := {,,,}
	self:aPosCmpSel       := {,,,}	
	self:aPosGetSearch    := {,,,}
	self:aPosBtnSearch    := {,,,}		
	self:aPosGetRename    := {,,,}
	self:aPosBtnRename    := {,,,}	
	self:aPosCmbConfig    := {,,,}
	self:aPosGetNewConfig := {,,,}
	self:aPosCmbTabela    := {,,,}
	self:oDlgWin          := NIL		
	self:befAdd           := {|| .T.}
	self:nPosSearch       := 1
	self:lAllToDisp       := .F.
RETURN

//-------------------------------------------------------------------                                                   
/*/{Protheus.doc} Activate            
ConstruÁ„o da classe       

@author Juliana Iwayama Velho / Rodrigo Antonio
@since 11/12/09
@version 1.0
/*/
//------------------------------------------------------------------- 
METHOD Activate(nQtMemo) CLASS JurLstBoxD  
Local cGetSearch := Space(15)
Local nList := 1   
Default nQtMemo := 0

self:SetRename(Space(30))    
                                   
self:oCmpDisp           := tListBox():New( C(::GetPosCmpDisp()[anRow]),C(::GetPosCmpDisp()[anCol]),,self:GetItemsAry(::GetCmpDisp()),C(::GetPosCmpDisp()[anWidth]),C(::GetPosCmpDisp()[anHeight]),,::GetDlgWin(),,,,.T.)
self:oCmpSel            := tListBox():New( C(::GetPosCmpSel()[anRow]),C(::GetPosCmpSel()[anCol]),,self:GetItemsAry(::GetCmpSel()),C(::GetPosCmpSel()[anWidth]),C(::GetPosCmpSel()[anHeight]),,::GetDlgWin(),,,,.T.)
self:oCmbTabela         := TComboBox():New(C(::GetPosCmbTabela()[anRow]),C(::GetPosCmbTabela()[anCol]),{|u|if(Pcount()>0,::SetTabela(u),::GetTabela())},self:GetItemsAry(self:GetCmbTabela()),C(::GetPosCmbTabela()[anWidth]),C(::GetPosCmbTabela()[anHeight]),::GetDlgWin(),,{||self:RefreshCmps ()},,,,.T.,,,,,,,,,'cCmbTabela')	

If ::GetEnabSch()
	::oGetSearch        := TGet():New( C(::GetPosGetSearch()[anRow]),C(::GetPosGetSearch()[anCol]),{|u|if(Pcount()>0,cGetSearch:=u,cGetSearch)},::GetDlgWin(),C(::GetPosGetSearch()[anWidth]),C(::GetPosGetSearch()[anHeight]),"@!",,0,,,.F.,,.T.,,.F.,,.F.,.F.,,.F.,.F.,,'cGetSearch',,,, )
	::oButtonSearch     := TButton():New( C(::GetPosBtnSearch()[anRow]),C(::GetPosBtnSearch()[anCol]),STR0001,::GetDlgWin(),{ ||::Search(cGetSearch) },C(::GetPosBtnSearch()[anWidth]),C(::GetPosBtnSearch()[anHeight]),,,.F.,.T.,.F.,,.F.,,,.F. )
EndIf	  

If self:GetEnabRen()
	::oGetRename        := TGet():New( C(::GetPosGetRename()[anRow]),C(::GetPosGetRename()[anCol]),{|u|if(Pcount()>0,::SetRename(u),::GetRename())},::GetDlgWin(),C(::GetPosGetRename()[anWidth]),C(::GetPosGetRename()[anHeight]),,,0,,,.F.,,.T.,,.F.,,.F.,.F.,,.F.,.F.,,'cGetRename',,,, )
	::oButtonRename     := TButton():New( C(::GetPosBtnRename()[anRow]),C(::GetPosBtnRename()[anCol]),STR0002,::GetDlgWin(),{ ||::Rename() },C(::GetPosBtnRename()[anWidth]),C(::GetPosBtnRename()[anHeight]),,,.F.,.T.,.F.,,.F.,,,.F. )
EndIf

If self:GetEnabConfig() 
	self:oCmbConfig     := TComboBox():New(C(::GetPosCmbConfig()[anRow]),C(::GetPosCmbConfig()[anCol]),{|u|if(Pcount()>0,::SetConfig(u),::GetConfig())},self:GetItemsAry(self:GetCmbConfig()),C(::GetPosCmbConfig()[anWidth]),C(::GetPosCmbConfig()[anHeight]),::GetDlgWin(),,{||self:RefreshConfig ()},,,,.T.,,,,,,,,,'cCmbConfig')	
	self:oGetNewConfig  := TGet():New( C(::GetPosGetNewConfig()[anRow]),C(::GetPosGetNewConfig()[anCol]),{|u|if(Pcount()>0,::SetNewConfig(u),::GetNewConfig())},::GetDlgWin(),C(::GetPosGetNewConfig()[anWidth]),C(::GetPosGetNewConfig()[anHeight]),,,0,,,.F.,,.T.,,.F.,,.F.,.F.,,.F.,.F.,,'cGetNewConfig',,,, )
EndIf


self:oCmpDisp:blDblClick:= { ||::AddOne(::oCmpDisp,::oCmpSel,::aCmpDisp,::aCmpSel,,,@nQtMemo )}
self:oCmpSel:blDblClick := { ||::OneToDisp(@nQtMemo)}       
self:lActivate := .T.     

Return (Nil)                  

//-------------------------------------------------------------------                                                   
/*/{Protheus.doc} Activate            
Move um elemento da ListBox passado no primeiro parametro para o segundo      

@param	oObj1    	Listbox de campos disponÌveis
@param	oObj2       Listbox de campos selecionados
@param	aOrigem     Array de campos disponÌveis
@param	aDestino    Array de campos selecionados

@author Juliana Iwayama Velho / Rodrigo Antonio
@since 11/12/09
@version 1.0
/*/
//------------------------------------------------------------------- 
METHOD AddOne(oObj1,oObj2,aOrigem,aDestino,lAdd,lRem,nQtMemo) CLASS JurLstBoxD
Default lAdd := .T.
Default lRem := .F.
Default nQtMemo := 0

if (Eval(self:befAdd,oObj1,oObj2,aOrigem,aDestino,lRem))
	if lAdd
		If Len(aOrigem[oObj1:nAT]) > 5 .And. aOrigem[oObj1:nAT][9] == "M"
			If !lRem
				nQtMemo := nQtMemo + 1
		 		If nQtMemo > 1
					If ApMsgYesNo(STR0006 + aOrigem[oObj1:nAT][1] + STR0007)	//"O campo ("	//") È do tipo Memo, este tipo de campo (Memo) pode causar lentid„o na exportaÁ„o dos dados. Confirma a seleÁ„o deste campo? "
						aAdd(aDestino,aOrigem[oObj1:nAT]) 
						aDel (aOrigem,oObj1:nAT)	
						aOrigem := APack(aOrigem, .F.)		
		  			EndIf
		  		Else
					aAdd(aDestino,aOrigem[oObj1:nAT]) 
					aDel (aOrigem,oObj1:nAT)	
					aOrigem := APack(aOrigem, .F.)		
		  		EndIf
		  	Else
				nQtMemo := nQtMemo - 1
				aAdd(aDestino,aOrigem[oObj1:nAT]) 
				aDel (aOrigem,oObj1:nAT)	
				aOrigem := APack(aOrigem, .F.)		
		  	EndIf 
		Else
			//Apenas inclui o campo no destino caso tenha tabela selecionada no combo e seja a mesma do campo, para nao incluir o campo quando nao tem nenhuma tabela selecionada ou em tabela errada
			If (Len(aOrigem[oObj1:nAT]) > 5 .And. ((self:cCmbTabApe == aOrigem[oObj1:nAT][6]) .Or. (self:cCmbTabApe == aOrigem[oObj1:nAT][7]) .Or. (self:cCmbTabApe == aOrigem[oObj1:nAT][5]))) .Or. (Len(aOrigem[oObj1:nAT]) == 5 .And. self:cCmbTabApe == aOrigem[oObj1:nAT][4])    //Formula	
				aAdd(aDestino,aOrigem[oObj1:nAT])
			ElseIf Len(aOrigem[oObj1:nAT]) == 3 // Usado para alteraÁ„o de grupos em lote (JURA218)
				aAdd(aDestino,aOrigem[oObj1:nAT])
			EndIf	
			aDel (aOrigem,oObj1:nAT)	
			aOrigem := APack(aOrigem, .F.)		
		EndIf
	EndIf	
	oObj2:Reset()
	oObj1:Reset()
	If !Empty(aOrigem)
		oObj1:aItems  := self:GetItemsAry(aOrigem)
		oObj1:nAT 	  := 1	
	Endif
	oObj2:aItems  := self:GetItemsAry(aDestino)
	oObj2:nAT 	  := 1	
	
Endif	

Return   

//-------------------------------------------------------------------                                                   
/*/{Protheus.doc} AddAll            
Move todos elementos da origem para o Destino   

@param	oObj1    	Listbox de campos disponÌveis
@param	oObj2       Listbox de campos selecionados
@param	aOrigem     Array de campos disponÌveis
@param	aDestino    Array de campos selecionados   

@author Juliana Iwayama Velho / Rodrigo Antonio
@since 11/12/09
@version 1.0
/*/
//------------------------------------------------------------------- 
METHOD AddAll (oObj1,oObj2,aOrigem,aDestino,aAdic,nQtMemo) Class JurLstBoxD
Local nx
Local lRet := .T.
Local nQtdAnt := 0
Local nCount := 0
Default aAdic := {}
Default nQtMemo := 0

nQtdAnt := nQtMemo

If !Empty(aOrigem)

	For nX := 1 to Len (aOrigem)	
		If Len(aOrigem[nX]) > 5 .And. aOrigem[nX][9] == "M" 
			nQtMemo := nQtMemo + 1
		EndIf
	Next
	If ApMsgYesNo(STR0010)	//"Deseja continuar a exportaÁao sem nenhum filtro dos campos, pois isso vai ocasionar demora na emiss„o do relatorio.? "

		If nQtMemo > 1 .and. Empty (aAdic)
			If ApMsgYesNo(STR0008 + Str(nQtMemo) + STR0009)	//"Existem na seleÁ„o "		//" campos do tipo Memo, este tipo de campo (Memo) pode causar lentid„o na exportaÁ„o dos dados. Confirma a seleÁ„o deste campo? "
				nQtMemo := nQtdAnt
				For nX := 1 to Len (aOrigem)	
					If Len(aOrigem[nX]) > 5 .And. aOrigem[nX][9] == "M" 
						nQtMemo := nQtMemo + 1
					EndIf
					If lRet .And. Eval(self:befAdd,aOrigem[nX],oObj2,aOrigem,aDestino)
						aAdd(aDestino,aOrigem[nX])
						aDel (aOrigem,nX)	
						ASize( aOrigem, (Len (aOrigem)-1) )	
					Else
						lRet := .F.
					Endif
					nX := nX - 1
					If nx >= Len (aOrigem)
						Exit
					EndIf
				Next
			Else
				nQtMemo := nQtdAnt
				For nX := 1 to Len (aOrigem)
					If Len(aOrigem[nX]) == 5 .And. aOrigem[nX][9] <> "M" 
						If lRet .And. Eval(self:befAdd,aOrigem[nX],oObj2,aOrigem,aDestino)
							aAdd(aDestino,aOrigem[nX])
							aDel (aOrigem,nX)
							ASize( aOrigem, (Len (aOrigem)-1) )	
						Else
							lRet := .F.
						Endif
						nX := nX - 1
					EndIf  
					If nx >= Len (aOrigem)
						Exit
					EndIf
				Next
			EndIf
		ElseIf ! Empty (aAdic)
			For nX := 1 to Len (aAdic)
				If lRet .And. Eval(self:befAdd,aAdic[nX],oObj2,aOrigem,aDestino, .T. /*lRem*/)	
					aAdd(aDestino,aAdic[nX])
				Else
					lRet := .F.
				Endif
			Next
			If lRet
				aOrigem := {}
				nQtMemo := 0
			EndIf
		Else
			For nX := 1 to Len (aOrigem)	
				If lRet .And. Eval(self:befAdd,aOrigem[nX],oObj2,aOrigem,aDestino)
					aAdd(aDestino,aOrigem[nX])
				Else
					lRet := .F.
				Endif
			Next
			If lRet
				aOrigem := {}
			EndIf
		EndIf
	EndIf  
	
	If lRet
		oObj1:Reset()
		oObj2:Reset()
		oObj1:aItems  := self:GetItemsAry(aOrigem)
		oObj2:aItems  := self:GetItemsAry(aDestino)
		oObj2:nAT 	  := 1	
	Endif
Endif
Return

//-------------------------------------------------------------------                                                   
/*/{Protheus.doc} OneToSel            
Move o campo disponÌvel para o selecionado  

@author Juliana Iwayama Velho / Rodrigo Antonio
@since 11/12/09
@version 1.0
/*/
//------------------------------------------------------------------- 
METHOD OneToSel (nQtMemo) Class JurLstBoxD
Default nQtMemo := 0 
    If ::oCmpDisp:nAT > 0 
    	IF !Empty( self:aCmpDisp )	
    		::AddOne(::oCmpDisp,::oCmpSel,@::aCmpDisp,@::aCmpSel,,,@nQtMemo)
    	Endif
    Endif		 
Return

//-------------------------------------------------------------------                                                   
/*/{Protheus.doc} OneToDisp            
Move o campo selecionado para o disponÌvel   

@author Juliana Iwayama Velho / Rodrigo Antonio
@since 11/12/09
@version 1.0
/*/
//------------------------------------------------------------------- 
METHOD OneToDisp (nQtMemo) Class JurLstBoxD
Local aCampo:= {}
Default nQtMemo := 0

If ::oCmpSel:nAT > 0
	aCampo := EVal(self:bRemove,self)
		If !Empty(aCampo)
			::AddOne(::oCmpSel,::oCmpDisp,@::aCmpSel,@::aCmpDisp,!Empty(aCampo),.T./*lRem*/,@nQtMemo)
			::bRefresh := aCampo
	    Endif	
EndIf

Return

//-------------------------------------------------------------------                                                   
/*/{Protheus.doc} AllToSel            
Move todos para o list de campo selecionados   

@author Juliana Iwayama Velho / Rodrigo Antonio
@since 11/12/09
@version 1.0
/*/
//------------------------------------------------------------------- 
METHOD AllToSel (nQtMemo) Class JurLstBoxD
	If !Empty( self:aCmpDisp )
		::AddAll (::oCmpDisp,::oCmpSel,@::aCmpDisp,@::aCmpSel,,@nQtMemo)
	EndIf
Return

//-------------------------------------------------------------------                                                   
/*/{Protheus.doc} AllToDisp            
Move todos para o list de campos disponÌveis   

@author Juliana Iwayama Velho / Rodrigo Antonio
@since 11/12/09
@version 1.0
/*/
//------------------------------------------------------------------- 
METHOD AllToDisp (nQtMemo) Class JurLstBoxD     
Local aRemover := {}

self:lAllToDisp := .T.	 

If !Empty( self:aCmpSel ) .And. ( !Empty( self:aCmpDisp ) .Or. !Empty(self:GetTabela()) )

	aRemover := EVal(self:bRemove,self)

	If !Empty (aRemover)
		::AddAll (::oCmpSel,::oCmpDisp,@::aCmpSel,@::aCmpDisp,aRemover,@nQtMemo)
	Else
  	    self:oCmpSel:Reset()
		self:SetCmpSel({})
	EndIf
Else
	self:oCmpDisp:Reset()
	self:SetCmpDisp({})
	self:oCmpSel:Reset()  
	self:SetCmpSel({})
EndIf

self:lAllToDisp := .F.

Return

//-------------------------------------------------------------------                                                   
/*/{Protheus.doc} AllToDisp            
Desabilita o Duplo click dos objetos listBox   

@author Juliana Iwayama Velho / Rodrigo Antonio
@since 11/12/09
@version 1.0
/*/
//------------------------------------------------------------------- 
METHOD DisaDbClic() Class JurLstBoxD
::oCmpDisp:blDblClick:= {|| Nil }
::oCmpSel:blDblClick:= {|| Nil }
Return                            

//-------------------------------------------------------------------                                                   
/*/{Protheus.doc} GetItemsAry            
Monta um array com layout   

@author Juliana Iwayama Velho
@since 21/01/10
@version 1.0
/*/
//------------------------------------------------------------------- 
METHOD GetItemsAry(aOrigem) Class JurLstBoxD
Local aTmp  := {}
Local nX
For nX := 1 to Len (aOrigem)
	aAdd(aTmp,aOrigem[nX][1] + aOrigem[nX][2])
Next nX                    
Return aTmp

/*Static Function getAryNome(aOrigem)
Local aTmp  := {}
Local nX
For nX := 1 to Len (aOrigem)
	aAdd(aTmp,AllTrim(aOrigem[nX][1]) + AllTrim(aOrigem[nX][2]))
Next nX                    
Return aTmp
*/

/*
‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±…ÕÕÕÕÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÀÕÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÀÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕÕÕª±±
±±∫Programa  ≥APack     ∫Autor  ≥Norbert/Ernani      ∫ Data ≥  03/03/05   ∫±±
±±ÃÕÕÕÕÕÕÕÕÕÕÿÕÕÕÕÕÕÕÕÕÕ ÕÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕ ÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕπ±±
±±∫Desc.     ≥Remove os itens nao selecionados do array(aCols ou nao)     ∫±±
±±ÃÕÕÕÕÕÕÕÕÕÕÿÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕπ±±
±±∫Parametros≥aPar1 - Array a ser tratado pela rotina                     ∫±±
±±∫          ≥lPar1 - Logico que indica se o array tem a estrutura de um  ∫±±
±±∫          ≥        aCols.                                              ∫±±
±±ÃÕÕÕÕÕÕÕÕÕÕÿÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕπ±±
±±∫Uso       ≥Generico                                                    ∫±±
±±»ÕÕÕÕÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕº±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
*/
Static Function APack(_aArray, _laCols)

Local _nCont	:=	0
Local _aRet		:=	{}

_laCols := IIf( _laCols == NIL, .F., _laCols)

If _laCols
	
	// aPack para aCols
	For _nCont := 1 to Len(_aArray)
		//Se a linha nao foi deletada
		If !ATail(_aArray[_nCont])
			aAdd(_aRet,_aArray[_nCont])
		EndIf
	Next _nCont
	
Else
	
	// aPack para qualquer Array
	For _nCont := 1 to Len(_aArray)
		
		//Se o elemento nao foi deletado
		If _aArray[_nCont] <> NIL
			If ValType(_aArray[_nCont]) == "A"
				_aArray[_nCont] := aPack(_aArray[_nCont])
				If !Empty(_aArray[_nCont])
					aAdd(_aRet,_aArray[_nCont])
				EndIf
			Else
				aAdd(_aRet,_aArray[_nCont])
			EndIf
		EndIf
		
	Next _nCont
	
EndIf

Return _aRet         

STatic Function C(nT)
Return nT

//-------------------------------------------------------------------                                                   
/*/{Protheus.doc} ChangeOne            
Muda o campo da lista da exportaÁ„o para cima ou baixo
Uso Geral.

@param 	oObj  		Objeto (listbox) de campos da exportaÁ„o	
@param 	aCampos 	Array dos campos da exportaÁ„o
@param 	nStep  		1 - move para cima / - 1 - move para baixo 

@author Juliana Iwayama Velho / Ernani Forastieri
@since 11/12/09
@version 1.0
/*/
//-------------------------------------------------------------------
METHOD ChangeOne (oObj,aCampos,nStep)  CLASS JurLstBoxD
Local aAux       := {} 
Local nPos       := oObj:nAT

If ( oObj:nAT > 1 .and. nStep > 0 ) .or. ( oObj:nAT < Len( aCampos ) .and. nStep < 0 )
	aAux                  := aClone( aCampos[nPos] )
	aCampos[nPos]         := aClone( aCampos[nPos -nStep] )
	aCampos[nPos - nStep] := aClone( aAux )
    
	nPos := Min( Max( 0, oObj:nAT - nStep ), Len( aCampos ) )

	If !Empty(aCampos)
		oObj:Reset()
		oObj:aItems  := self:GetItemsAry(aCampos)	 
	Endif

	oObj:nAt := nPos
	oObj:SetFocus()
	oObj:Refresh()
EndIf

Return           

//-------------------------------------------------------------------                                                   
/*/{Protheus.doc} OneToDown            
Move um campo da lista da exportaÁ„o para cima
Uso Geral.

@author Juliana Iwayama Velho / Ernani Forastieri
@since 11/12/09
@version 1.0
/*/
//-------------------------------------------------------------------             
METHOD MoveUp () Class JurLstBoxD 
If ::oCmpSel:nAT > 0
	::ChangeOne (::oCmpSel,::aCmpSel,1)
EndIf	
Return

//-------------------------------------------------------------------                                                   
/*/{Protheus.doc} OneToDown            
Move um campo da lista da exportaÁ„o para baixo
Uso Geral.

@author Juliana Iwayama Velho / Ernani Forastieri
@since 11/12/09
@version 1.0
/*/
//------------------------------------------------------------------- 
METHOD MoveDown () Class JurLstBoxD 
If ::oCmpSel:nAT > 0
	::ChangeOne (::oCmpSel,::aCmpSel,-1)
EndIf	
Return        

//-------------------------------------------------------------------                                                   
/*/{Protheus.doc} Search            
Pesquisa o campo digitado
Uso Geral.

@param 	cCampo  	TÌtulo a ser pesquisado	

@author Juliana Iwayama Velho / Ernani Forastieri
@since 11/12/09
@version 1.0
/*/
//------------------------------------------------------------------- 
METHOD Search (cCampo) Class JurLstBoxD 
If !Empty( AllTrim(cCampo) )
	::PesquisaCampo (::oCmpDisp,::aCmpDisp,cCampo)
EndIf	
Return

//-------------------------------------------------------------------                                                   
/*/{Protheus.doc} PesquisaCampo            
Pesquisa o campo digitado na lista de campos disponÌveis
Uso Geral.

@param 	oObj  		Objeto (listbox) de campos disponÌveis	
@param 	aCampos 	Array dos campos disponÌveis
@param 	cPesq  		TÌtulo a ser pesquisado	

@author Juliana Iwayama Velho / Ernani Forastieri
@since 11/12/09
@version 1.0
/*/
//-------------------------------------------------------------------   
METHOD PesquisaCampo( oObj,aCampos,cPesq ) Class JurLstBoxD
Local cAux        := AllTrim( cPesq )
Local nTam        := Len( cAux )
Local nPosArq, nPosIni

If !Empty( cAux ) 	   

	nPosIni := oObj:nAt
	
	If (nPosArq := aScan( aCampos, { |x| Upper( Alltrim( cPesq  ) ) $ Upper( x[self:nPosSearch]  ) } , nPosIni + 1) ) <> 0
		oObj:nAt      := nPosArq
	Else
		If (nPosArq := aScan( aCampos, { |x| Upper( Alltrim( cPesq  ) ) $ Upper( x[self:nPosSearch]  ) }) ) <> 0
			oObj:nAt      := nPosArq
		Else
			JurMsgErro(STR0003)
		EndIf
	EndIf
	
	oObj:Refresh()
	
EndIf

Return NIL      

//-------------------------------------------------------------------                                                   
/*/{Protheus.doc} GetCmpDisp            
Retorna o array de campos disponÌveis
Uso Geral.

@author Juliana Iwayama Velho
@since 11/12/09
@version 1.0
/*/
//-------------------------------------------------------------------  
METHOD GetCmpDisp () Class JurLstBoxD
Return ::aCmpDisp

//-------------------------------------------------------------------                                                   
/*/{Protheus.doc} SetCmpDisp            
Atribui o array de campos disponÌveis
Uso Geral.

@param  aDados Array de campos disponÌveis            

@author Juliana Iwayama Velho
@since 11/12/09
@version 1.0
/*/
//------------------------------------------------------------------- 
METHOD SetCmpDisp ( aDados ) Class JurLstBoxD  
	::aCmpDisp := aDados
Return Nil

//-------------------------------------------------------------------                                                   
/*/{Protheus.doc} GetCmpSel            
Retorna o array de campos selecionados
Uso Geral.

@author Juliana Iwayama Velho
@since 11/12/09
@version 1.0
/*/
//-------------------------------------------------------------------  
METHOD GetCmpSel () Class JurLstBoxD
Return ::aCmpSel    
                 
//-------------------------------------------------------------------                                                   
/*/{Protheus.doc} SetCmpSel            
Atribui o array de campos selecionados
Uso Geral.

@param  aDados Array de campos selecionados            

@author Juliana Iwayama Velho
@since 11/12/09
@version 1.0
/*/
//------------------------------------------------------------------- 
METHOD SetCmpSel ( aDados ) Class JurLstBoxD  
Local nI
For nI := 1 to len(aDados)
	//Valida os itens que ser„o incluÌdos.
	If Eval(self:befAdd,aDados[nI],,,::aCmpSel)
		aAdd(::aCmpSel, aDados[nI])
	Endif
Next
Return Nil

//-------------------------------------------------------------------                                                   
/*/{Protheus.doc} GetEnabSch            
Retorna se a pesquisa ser· mostrada ou n„o
Uso Geral.

@author Juliana Iwayama Velho
@since 11/12/09
@version 1.0
/*/
//-------------------------------------------------------------------  
METHOD GetEnabSch () Class JurLstBoxD
Return self:lEnableSearch

//-------------------------------------------------------------------                                                   
/*/{Protheus.doc} SetEnabSch            
Atribui o valor para mostrar a pesquisa ou n„o
Uso Geral.

@param  lValor .T./.F. Mostrar a pesquisa ou n„o            

@author Juliana Iwayama Velho
@since 11/12/09
@version 1.0
/*/
//-------------------------------------------------------------------  
METHOD SetEnabSch ( lValor ) Class JurLstBoxD
	self:lEnableSearch := lValor
Return Nil

//-------------------------------------------------------------------                                                   
/*/{Protheus.doc} GetPosCmpDisp            
Retorna o array de coordenadas do listbox de campos disponÌveis
Uso Geral.

@author Juliana Iwayama Velho
@since 11/12/09
@version 1.0
/*/
//------------------------------------------------------------------- 
METHOD GetPosCmpDisp () Class JurLstBoxD
Return self:aPosCmpDisp

//-------------------------------------------------------------------                                                   
/*/{Protheus.doc} SetPosCmpDisp            
Atribui o array de coordenadas do listbox de campos disponÌveis
Uso Geral.

@param  aPos Array de coordenadas            

@author Juliana Iwayama Velho
@since 11/12/09
@version 1.0
/*/
//------------------------------------------------------------------- 
METHOD SetPosCmpDisp ( aPos ) Class JurLstBoxD
	self:aPosCmpDisp := aPos
Return Nil

//-------------------------------------------------------------------                                                   
/*/{Protheus.doc} GetPosCmpSel            
Retorna o array de coordenadas do listbox de campos selecionados
Uso Geral.

@author Juliana Iwayama Velho
@since 11/12/09
@version 1.0
/*/
//------------------------------------------------------------------- 
METHOD GetPosCmpSel () Class JurLstBoxD
Return self:aPosCmpSel

//-------------------------------------------------------------------                                                   
/*/{Protheus.doc} SetPosCmpSel            
Atribui o array de coordenadas do listbox de campos selecinados
Uso Geral.

@param  aPos Array de coordenadas            

@author Juliana Iwayama Velho
@since 11/12/09
@version 1.0
/*/
//------------------------------------------------------------------- 
METHOD SetPosCmpSel ( aPos ) Class JurLstBoxD
	self:aPosCmpSel := aPos
Return Nil

//-------------------------------------------------------------------                                                   
/*/{Protheus.doc} GetPosGetSearch            
Retorna o array de coordenadas do campo de pesquisa
Uso Geral.

@author Juliana Iwayama Velho
@since 11/12/09
@version 1.0
/*/
//-------------------------------------------------------------------       
METHOD GetPosGetSearch () Class JurLstBoxD
Return self:aPosGetSearch

//-------------------------------------------------------------------                                                   
/*/{Protheus.doc} SetPosGetSearch            
Atribui o array de coordenadas do campo de pesquisa
Uso Geral.

@param  aPos Array de coordenadas            

@author Juliana Iwayama Velho
@since 11/12/09
@version 1.0
/*/
//-------------------------------------------------------------------
METHOD SetPosGetSearch ( aPos ) Class JurLstBoxD
	self:aPosGetSearch := aPos
Return Nil                                         

//-------------------------------------------------------------------                                                   
/*/{Protheus.doc} GetPosBtnSearch            
Retorna o array de coordenadas do bot„o de pesquisa
Uso Geral.

@author Juliana Iwayama Velho
@since 11/12/09
@version 1.0
/*/
//------------------------------------------------------------------- 
METHOD GetPosBtnSearch () Class JurLstBoxD
Return self:aPosBtnSearch

//-------------------------------------------------------------------                                                   
/*/{Protheus.doc} SetPosBtnSearch            
Atribui o array de coordenadas do bot„o de pesquisa
Uso Geral.

@param  aPos Array de coordenadas            

@author Juliana Iwayama Velho
@since 11/12/09
@version 1.0
/*/
//-------------------------------------------------------------------
METHOD SetPosBtnSearch ( aPos ) Class JurLstBoxD
	self:aPosBtnSearch := aPos
Return Nil  

//-------------------------------------------------------------------                                                   
/*/{Protheus.doc} GetDlgWin            
Retorna o objeto dialog
Uso Geral.

@author Juliana Iwayama Velho
@since 11/12/09
@version 1.0
/*/
//-------------------------------------------------------------------                        
METHOD GetDlgWin () Class JurLstBoxD
Return self:oDlgWin

//-------------------------------------------------------------------                                                   
/*/{Protheus.doc} SetDlgWin            
Atribui o o objeto dialog
Uso Geral.

@param  oObj Objeto dialog            

@author Juliana Iwayama Velho
@since 11/12/09
@version 1.0
/*/
//-------------------------------------------------------------------
METHOD SetDlgWin ( oObj ) Class JurLstBoxD
	self:oDlgWin := oObj
Return Nil  

//-------------------------------------------------------------------                                                   
/*/{Protheus.doc} GetPosGetRename            
Retorna o array de coordenadas do campo de renomeio
Uso Geral.

@author Juliana Iwayama Velho
@since 16/12/09
@version 1.0
/*/
//-------------------------------------------------------------------       
METHOD GetPosGetRename () Class JurLstBoxD
Return self:aPosGetRename

//-------------------------------------------------------------------                                                   
/*/{Protheus.doc} SetPosGetRename            
Atribui o array de coordenadas do campo de renomeio
Uso Geral.

@param  aPos Array de coordenadas            

@author Juliana Iwayama Velho
@since 16/12/09
@version 1.0
/*/
//-------------------------------------------------------------------
METHOD SetPosGetRename ( aPos ) Class JurLstBoxD
	self:aPosGetRename := aPos
Return Nil                                         

//-------------------------------------------------------------------                                                   
/*/{Protheus.doc} GetPosBtnRename            
Retorna o array de coordenadas do bot„o de renomeio
Uso Geral.

@author Juliana Iwayama Velho
@since 16/12/09
@version 1.0
/*/
//------------------------------------------------------------------- 
METHOD GetPosBtnRename () Class JurLstBoxD
Return self:aPosBtnRename

//-------------------------------------------------------------------                                                   
/*/{Protheus.doc} SetPosBtnRename            
Atribui o array de coordenadas do bot„o de renomeio
Uso Geral.

@param  aPos Array de coordenadas            

@author Juliana Iwayama Velho
@since 16/12/09
@version 1.0
/*/
//-------------------------------------------------------------------
METHOD SetPosBtnRename ( aPos ) Class JurLstBoxD
	self:aPosBtnRename := aPos
Return Nil
          
//-------------------------------------------------------------------                                                   
/*/{Protheus.doc} GetRename            
Retorna o tÌtulo novo do campo selecionado a ser renomeiado
Uso Geral.

@author Juliana Iwayama Velho
@since 16/12/09
@version 1.0
/*/
//------------------------------------------------------------------- 
METHOD GetRename () Class JurLstBoxD
Return self:cGetRename

//-------------------------------------------------------------------                                                   
/*/{Protheus.doc} SetRename            
Atribui o valor do novo tÌtulo a ser renomeado no campo selecionado
Uso Geral.

@param  lRet Array de coordenadas            

@author Juliana Iwayama Velho
@since 16/12/09
@version 1.0
/*/
//-------------------------------------------------------------------
METHOD SetRename ( cValor ) Class JurLstBoxD
	self:cGetRename := cValor
	If self:lActivate
		self:oGetRename:Refresh()
	EndIf
Return Nil
         
//-------------------------------------------------------------------                                                   
/*/{Protheus.doc} GetEnabRen            
Retorna o se os campos de renomear v„o aparecer
Uso Geral.

@author Juliana Iwayama Velho
@since 16/12/09
@version 1.0
/*/
//------------------------------------------------------------------- 
METHOD GetEnabRen () Class JurLstBoxD
Return self:lEnableRename
                      
//-------------------------------------------------------------------                                                   
/*/{Protheus.doc} SetRename            
Atribui se os campos de renomear v„o aparecer
Uso Geral.

@param  lValor .T./.F. As informaÁıes n„o aparecer ou n„o            

@author Juliana Iwayama Velho
@since 16/12/09
@version 1.0
/*/
//-------------------------------------------------------------------
METHOD SetEnabRen ( lValor ) Class JurLstBoxD
	self:lEnableRename := lValor
Return Nil    
         
//-------------------------------------------------------------------                                                   
/*/{Protheus.doc} Rename            
Renomeia o tÌtulo de um campo selecionado
Uso Geral.       

@author Juliana Iwayama Velho
@since 16/12/09
@version 1.0
/*/
//-------------------------------------------------------------------
METHOD Rename () Class JurLstBoxD
Local nPos := self:oCmpSel:nAT
If nPos > 0
	If !Empty (AllTrim(self:GetRename()))
		self:aCmpSel[self:oCmpSel:nAT][1] := AllTrim(self:GetRename())
		self:oCmpSel:Reset()
		self:oCmpSel:aItems  := self:GetItemsAry(self:aCmpSel)
		self:oCmpSel:nAt     := nPos
		self:oCmpSel:SetFocus()
		self:oCmpSel:Refresh()
		self:SetRename(Space(30))
	Else
		JurMsgErro(STR0005)
	EndIf
Else
	JurMsgErro(STR0004)
EndIf
Return Nil
           
//-------------------------------------------------------------------                                                   
/*/{Protheus.doc} GetEnabConfig            
Retorna o se os campos de configuraÁ„o v„o aparecer
Uso Geral.

@author Juliana Iwayama Velho
@since 29/12/09
@version 1.0
/*/
//------------------------------------------------------------------- 
METHOD GetEnabConfig () Class JurLstBoxD
Return self:lEnableConfig

//-------------------------------------------------------------------                                                   
/*/{Protheus.doc} GetPosCmbConfig            
Retorna o array de coordenadas da lista de configuraÁ„o
Uso Geral.

@author Juliana Iwayama Velho
@since 29/12/09
@version 1.0
/*/
//------------------------------------------------------------------- 
METHOD GetPosCmbConfig () Class JurLstBoxD
Return self:aPosCmbConfig

//-------------------------------------------------------------------                                                   
/*/{Protheus.doc} SetPosCmbConfig            
Atribui o array de coordenadas da lista de configuraÁ„o
Uso Geral.

@param  aPos Array de coordenadas            

@author Juliana Iwayama Velho
@since 29/12/09
@version 1.0
/*/
//-------------------------------------------------------------------
METHOD SetPosCmbConfig ( aPos ) Class JurLstBoxD
	self:aPosCmbConfig := aPos
Return Nil
                      
//-------------------------------------------------------------------                                                   
/*/{Protheus.doc} SetEnabConfig            
Atribui se os campos de configuraÁ„o v„o aparecer
Uso Geral.

@param  lValor .T./.F. As informaÁıes n„o aparecer ou n„o            

@author Juliana Iwayama Velho
@since 29/12/09
@version 1.0
/*/
//-------------------------------------------------------------------
METHOD SetEnabConfig ( lValor ) Class JurLstBoxD
	self:lEnableConfig := lValor
Return Nil 
 
//-------------------------------------------------------------------                                                   
/*/{Protheus.doc} GetConfig            
Retorna a configuraÁ„o
Uso Geral.

@author Juliana Iwayama Velho
@since 29/12/09
@version 1.0
/*/
//------------------------------------------------------------------- 
METHOD GetConfig () Class JurLstBoxD
Return self:cCmbConfig

//-------------------------------------------------------------------                                                   
/*/{Protheus.doc} SetConfig            
Atribui o valor na configuraÁ„o
Uso Geral.

@param  cValor ConfiguraÁ„o

@author Juliana Iwayama Velho
@since 29/12/09
@version 1.0
/*/
//-------------------------------------------------------------------
METHOD SetConfig ( cValor ) Class JurLstBoxD
self:cCmbConfig := cValor
Return Nil

//-------------------------------------------------------------------                                                   
/*/{Protheus.doc} GetCmbConfig            
Retorna o array de configuraÁıes
Uso Geral.

@author Juliana Iwayama Velho
@since 29/12/09
@version 1.0
/*/
//-------------------------------------------------------------------  
METHOD GetCmbConfig () Class JurLstBoxD
Return self:aCmbConfig    
                 
//-------------------------------------------------------------------                                                   
/*/{Protheus.doc} SetCmbConfig            
Atribui o array de configuraÁıes
Uso Geral.

@param  aDados Array de configuraÁıes            

@author Juliana Iwayama Velho
@since 29/12/09
@version 1.0
/*/
//------------------------------------------------------------------- 
METHOD SetCmbConfig ( aDados ) Class JurLstBoxD  
	self:aCmbConfig := aDados
Return Nil          

//-------------------------------------------------------------------                                                   
/*/{Protheus.doc} GetNewConfig            
Retorna a nova configuraÁ„o a ser salva
Uso Geral.

@author Juliana Iwayama Velho
@since 30/12/09
@version 1.0
/*/
//------------------------------------------------------------------- 
METHOD GetNewConfig () Class JurLstBoxD
Return self:cGetNewConfig

//-------------------------------------------------------------------                                                   
/*/{Protheus.doc} SetNewConfig            
Atribui o valor da nova configuraÁ„o a ser salva
Uso Geral.

@param  cValor Nova configuraÁ„o

@author Juliana Iwayama Velho
@since 30/12/09
@version 1.0
/*/
//-------------------------------------------------------------------
METHOD SetNewConfig ( cValor ) Class JurLstBoxD
	self:cGetNewConfig := cValor
Return Nil
             
//-------------------------------------------------------------------                                                   
/*/{Protheus.doc} GetPosGetNewConfig            
Retorna o array de coordenadas da posiÁ„o do campo de nova 
configuraÁ„o
Uso Geral.

@author Juliana Iwayama Velho
@since 30/12/09
@version 1.0
/*/
//------------------------------------------------------------------- 
METHOD GetPosGetNewConfig () Class JurLstBoxD
Return self:aPosGetNewConfig

//-------------------------------------------------------------------                                                   
/*/{Protheus.doc} SetPosGetNewConfig            
Atribui o array de coordenadas da posiÁ„o do campo de nova 
configuraÁ„o
Uso Geral.

@param  aPos Array de coordenadas            

@author Juliana Iwayama Velho
@since 30/12/09
@version 1.0
/*/
//-------------------------------------------------------------------
METHOD SetPosGetNewConfig ( aPos ) Class JurLstBoxD
	self:aPosGetNewConfig := aPos
Return Nil
           
//-------------------------------------------------------------------                                                   
/*/{Protheus.doc} SetSelect            
Atribui o bloco de comando de execuÁ„o ao selecionar um item na lista de
configuraÁ„o
Uso Geral.

@param  cValor Item selecionado            

@author Juliana Iwayama Velho
@since 04/01/10
@version 1.0
/*/
//-------------------------------------------------------------------                      
METHOD SetSelect ( cValor ) Class JurLstBoxD
	self:bSelect := cValor
Return Nil
             
//-------------------------------------------------------------------                                                   
/*/{Protheus.doc} GetSelect            
Retorna o bloco de comando de execuÁ„o ao selecionar um item na lista de
configuraÁ„o
Uso Geral.

@author Juliana Iwayama Velho
@since 04/01/10
@version 1.0
/*/
//-------------------------------------------------------------------             
METHOD GetSelect () Class JurLstBoxD
Return self:bSelect
           
//-------------------------------------------------------------------                                                   
/*/{Protheus.doc} RefreshConfig            
Atualiza as listas de campos disponÌveis e selecionados a partir de
item escolhido da lista de configuraÁ„o
Uso Geral.

@author Juliana Iwayama Velho
@since 04/01/10
@version 1.0
/*/
//-------------------------------------------------------------------                                                 	
METHOD RefreshConfig() Class JurLstBoxD
Local aConfig := EVal(self:bSelect,self)

self:oCmpDisp:Reset()
self:oCmpSel:Reset() 
self:setTabela('')
self:SetCmpSel(aConfig)
self:oCmpSel:aItems := self:GetItemsAry(aConfig)

Return Nil

//-------------------------------------------------------------------                                                   
/*/{Protheus.doc} GetTabela            
Retorna a tabela para listar os campos disponÌveis
Uso Geral.

@author Juliana Iwayama Velho
@since 08/01/10
@version 1.0
/*/
//------------------------------------------------------------------- 
METHOD GetTabela () Class JurLstBoxD
Return self:cCmbTabela

//-------------------------------------------------------------------                                                   
/*/{Protheus.doc} SetTabela            
Atribui o valor da tabela para listar os campos disponÌveis
Uso Geral.

@param  cValor Tabela

@author Juliana Iwayama Velho
@since 08/01/10
@version 1.0
/*/
//-------------------------------------------------------------------
METHOD SetTabela ( cValor ) Class JurLstBoxD

	self:cCmbTabela := cValor
	
	self:cCmbTabApe := JurGetDados("NQ0", 1, xFilial("NQ0") + self:cCmbTabela, "NQ0_APELID")	//NQ0_FILIAL, NQ0_COD	- Apelido da tabela
	
	//Caso a cCmbTabApe esteja em branco o campo n„o È adicionado na lista de campos selecionados.
	//Isso acontece quando se usa a tela de campos em lote, pois na exportaÁ„o person. a cValor fica com o cÛdigo da configuraÁ„o personalizada da tabela,
	//j· a tela de campos em lote traz a cValor com o nome da tabela
	If Empty(self:cCmbTabApe)
		self:cCmbTabApe := cValor
	EndIf
	
Return Nil

//-------------------------------------------------------------------                                                   
/*/{Protheus.doc} GetCmbTabela            
Retorna o array de tabelas
Uso Geral.

@author Juliana Iwayama Velho
@since 08/01/10
@version 1.0
/*/
//-------------------------------------------------------------------  
METHOD GetCmbTabela () Class JurLstBoxD
Return self:aCmbTabela    
                 
//-------------------------------------------------------------------                                                   
/*/{Protheus.doc} SetCmbTabela            
Atribui o array de tabelas
Uso Geral.

@param  aDados Array de tabelas            

@author Juliana Iwayama Velho
@since 08/01/10
@version 1.0
/*/
//------------------------------------------------------------------- 
METHOD SetCmbTabela ( aDados ) Class JurLstBoxD  
	self:aCmbTabela := aDados
Return Nil

//-------------------------------------------------------------------                                                   
/*/{Protheus.doc} GetPosCmbTabela            
Retorna o array de coordenadas da lista de tabelas
Uso Geral.

@author Juliana Iwayama Velho
@since 08/01/10
@version 1.0
/*/
//------------------------------------------------------------------- 
METHOD GetPosCmbTabela () Class JurLstBoxD
Return self:aPosCmbTabela

//-------------------------------------------------------------------                                                   
/*/{Protheus.doc} SetPosCmbTabela            
Atribui o array de coordenadas da lista de tabelas
Uso Geral.

@param  aPos Array de coordenadas            

@author Juliana Iwayama Velho
@since 08/01/10
@version 1.0
/*/
//-------------------------------------------------------------------
METHOD SetPosCmbTabela ( aPos ) Class JurLstBoxD
	self:aPosCmbTabela := aPos
Return Nil

METHOD RefreshCmps() Class JurLstBoxD 
Local aConfig := EVal(self:bSelectTab,self)

self:oCmpDisp:Reset() 

If !Empty ( aConfig )
	self:SetCmpDisp(aConfig) 
	self:oCmpDisp:aItems := self:GetItemsAry(aConfig)
Else
	self:SetCmpDisp( {} ) 
	self:oCmpDisp:aItems := {}
EndIf

Return Nil

//-------------------------------------------------------------------                                                   
/*/{Protheus.doc} SetSelectTab            
Atribui o bloco de comando de execuÁ„o ao selecionar um item na lista de
tabelas
Uso Geral.

@param  cValor Item selecionado            

@author Juliana Iwayama Velho
@since 08/01/10
@version 1.0
/*/
//-------------------------------------------------------------------                      
METHOD SetSelectTab ( cValor ) Class JurLstBoxD
	self:bSelectTab := cValor
Return Nil
             
//-------------------------------------------------------------------                                                   
/*/{Protheus.doc} GetSelectTab            
Retorna o bloco de comando de execuÁ„o ao selecionar um item na lista de
tabelas
Uso Geral.

@author Juliana Iwayama Velho
@since 08/01/10
@version 1.0
/*/
//-------------------------------------------------------------------             
METHOD GetSelectTab () Class JurLstBoxD
Return self:bSelectTab     

//-------------------------------------------------------------------                                                   
/*/{Protheus.doc} SetRemove            
Atribui o bloco de comando de execuÁ„o ao remover algum campo da lista
de exportaÁ„o
Uso Geral.

@param  cValor Campo(s) selecionado (s)

@author Juliana Iwayama Velho
@since 08/01/10
@version 1.0
/*/
//-------------------------------------------------------------------
METHOD SetRemove ( cValor ) Class JurLstBoxD
	self:bRemove := cValor
Return Nil    

//-------------------------------------------------------------------                                                   
/*/{Protheus.doc} GetRemove            
Retorna o bloco de comando de execuÁ„o ao remover algum campo da lista
de exportaÁ„o
Uso Geral.

@author Juliana Iwayama Velho
@since 08/01/10
@version 1.0
/*/
//-------------------------------------------------------------------
METHOD GetRemove () Class JurLstBoxD
Return self:bRemove 

//-------------------------------------------------------------------                                                   
/*/{Protheus.doc} SetRefresh            
Atribui o bloco de comando de execuÁ„o ao selecionar um item na lista de
configuraÁ„o
Uso Geral.

@param  cValor Item selecionado            

@author Juliana Iwayama Velho
@since 04/01/10
@version 1.0
/*/
//-------------------------------------------------------------------                      
METHOD SetRefresh ( cValor ) Class JurLstBoxD
	self:bRefresh := cValor
Return Nil

//-------------------------------------------------------------------                                                   
/*/{Protheus.doc} RefreshDados            
Atualiza as listas de campos disponÌveis e selecionados a partir de
item escolhido da lista de configuraÁ„o
Uso Geral.

@author Juliana Iwayama Velho
@since 04/01/10
@version 1.0
/*/
//-------------------------------------------------------------------                                                 	
METHOD RefreshDados() Class JurLstBoxD
Local aConfig := EVal(self:bRefresh,self)

self:oCmpSel:Reset() 
self:setTabela('')
self:SetCmpSel(aConfig)
self:oCmpSel:aItems := self:GetItemsAry(aConfig)

Return Nil

//-------------------------------------------------------------------                                                   
/*/{Protheus.doc} GetRemove            
Retorna o bloco de comando de execuÁ„o ao remover algum campo da lista
de exportaÁ„o
Uso Geral.

@author Juliana Iwayama Velho
@since 08/01/10
@version 1.0
/*/
//-------------------------------------------------------------------
METHOD GetaRemove () Class JurLstBoxD
Return self:aRemove 

//-------------------------------------------------------------------                                                   
/*/{Protheus.doc} SetRefresh            
Atribui o bloco de comando de execuÁ„o ao selecionar um item na lista de
configuraÁ„o
Uso Geral.

@param  cValor Item selecionado            

@author Juliana Iwayama Velho
@since 04/01/10
@version 1.0
/*/
//-------------------------------------------------------------------                      
METHOD SetaRemove ( aValor ) Class JurLstBoxD
	self:aRemove := aValor
Return Nil

//-------------------------------------------------------------------                                                   
/*/{Protheus.doc} Deactivate            
Libera os componentes utilizados    
@author AndrÈ Spirigoni Pinto
@since 05/11/15
@version 1.0 
/*/
//------------------------------------------------------------------- 
METHOD Deactivate()CLASS JurLstBoxD   

//libera memÛria dos arrays
aSize(self:aCmpDisp,0)
aSize(self:aCmpSel,0)
aSize(self:aCmbConfig,0)
aSize(self:aCmbTabela,0)
aSize(self:aRemove,0)    
aSize(self:aPosCmpDisp,0)
aSize(self:aPosCmpSel,0)     
aSize(self:aPosGetSearch,0)
aSize(self:aPosBtnSearch,0)        
aSize(self:aPosGetRename,0)
aSize(self:aPosBtnRename,0)  
aSize(self:aPosCmbConfig,0)
aSize(self:aPosGetNewConfig,0)
aSize(self:aPosCmbTabela,0)
self:oDlgWin          := NIL       
           
self:lActivate        := .F.
      
RETURN

//-------------------------------------------------------------------                                                   
/*/{Protheus.doc} RefreshUsers
Atualiza as listas de usu·rios disponÌveis e selecionados a partir de
item escolhido da lista de configuraÁ„o
Uso Geral.

@author Jorge Luis Branco Martins Junior
@since 13/06/16
@version 1.0
/*/
//-------------------------------------------------------------------                                                 	
METHOD RefreshUsers() Class JurLstBoxD
Local aConfig := EVal(self:bRefresh,self)

self:oCmpSel:Reset() 
//self:setTabela('')

aSize(::aCmpSel,0)

self:SetCmpSel({})
self:SetCmpSel(aConfig)
self:oCmpSel:aItems := self:GetItemsAry(aConfig)

Return Nil

//-------------------------------------------------------------------                                                   
/*/{Protheus.doc} SetNSearch
Seta posiÁ„o o array de campos/usu·rios disponÌveis em que deseja
efetuar a pesquisa. Por padr„o ser· sempre a posiÁ„o 1
Uso Geral.

@author Jorge Luis Branco Martins Junior
@since 14/06/16
@version 1.0
/*/
//-------------------------------------------------------------------                                                 	
METHOD SetNSearch(nPos) Class JurLstBoxD
	self:nPosSearch := nPos
Return Nil