#INCLUDE "TOTVS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "MSOBJECT.CH"

//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴
//� Define
//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴
#DEFINE IDX_F_DATA 1 
//-------------------------------------------------------------------
/*/{Protheus.doc} PLSREGIC
Retorna o obj com registro correspondente ou colecao de dados acesso
ao banco

@author Alexander Santos
@since 20/02/2011
@version P11
/*/
//-------------------------------------------------------------------
Class PLSREGIC From PLSSTRUC

DATA lFound as logic

METHOD New() Constructor

METHOD GetCountReg(cAlias,aChave)
METHOD GetDadReg(cAlias,nIdx,cChave,nRecno,lRegMemory,lStru)
METHOD GetDadBx3(aDad,cOperad,cTipoAc,cCodUsuDef,cTipoRe)
METHOD GetBx3Ace(cAlias,cOperad)

METHOD Destroy()

endClass                   
//-------------------------------------------------------------------
/*/{Protheus.doc} New
Construtor da Class

@author Alexander Santos
@since 16/02/2011
@version P11
/*/
//-------------------------------------------------------------------
METHOD New() Class PLSREGIC
Return Self                
//-------------------------------------------------------------------
/*/{Protheus.doc} GetDadReg
Retorna informacao do registro

@author Alexander Santos
@since 20/02/2011
@version P11
/*/
//-------------------------------------------------------------------
METHOD GetDadReg(cAlias,nIdx,cChave,nRecno,lRegMemory,lStru,cFields) Class PLSREGIC
LOCAL aArea      	:= GetArea()
LOCAL nHoraBase 		:= Seconds()
LOCAL nI 		 		:= 1
LOCAL aStru			:= {}
DEFAULT nIdx   		:= 0
DEFAULT cChave	 	:= ""        
DEFAULT nRecno	 	:= 0
DEFAULT lRegMemory	:= .F.
DEFAULT lStru		:= .T.
DEFAULT cFields		:= ""
DEFAULT ::lFound 	:= .F.                            
//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴
//� Verifica se foi informado o idx e chave									 
//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴
If nIdx > 0 .And. len(cChave)>0 .Or. nRecno <> 0
	//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴
	//� Verifica se o registro existe											 
	//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴
	If nRecno == 0
		(cAlias)->( DbSetOrder(nIdx) )
		::lFound := (cAlias)->( MsSeek(cChave) )
	Else
		(cAlias)->( DbGoto(nRecno) )
		::lFound := !(cAlias)->( Eof() )
	EndIf	
	//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴
	//� Retorna o registro posicionado
	//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴
	If ::lFound .And. lStru
		//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
		//� Monta M																	 
		//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
		If lRegMemory
			Inclui	  := .F.
			lJuridico := .T.   

			RegToMemory(cAlias,.F.)
		EndIf	
		//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
		//� Retorna estrutura da tabela												 
		//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
		aStru := _Super:New(cAlias,,,,,cFields):GetData()      
		//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
		//� Campos da Estrutura														 
		//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
		For nI:=1 To Len(aStru)
			If lRegMemory
				_Super:SetValue(aStru[nI,IDX_F_DATA], M->&(aStru[nI,IDX_F_DATA]) )
			Else                                                 
				If (cAlias)->( FieldPos( aStru[nI,IDX_F_DATA] ) ) > 0 
					_Super:SetValue(aStru[nI,IDX_F_DATA], (cAlias)->&(aStru[nI,IDX_F_DATA]) )
				EndIf	
			EndIf	
		Next
		//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴
		//� Fecha area
		//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴
		If lRegMemory
			M->( DbCloseArea() )
		EndIf	
	EndIf
EndIf	             
//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴
//� Restaura area															 
//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴
RestArea( aArea )       
//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴
//� Dura豫o
//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴
_Super:SetLog(nHoraBase)
//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴
//� Fim do metodo															 
//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴
Return(Self)                                           
//-------------------------------------------------------------------
/*/ { Protheus.doc } GetCountReg
Retorna a quantidade de registro de uma Tabela usando Query.

@author Alexander Santos
@since 02/02/11
@version 1.0
/*/
//-------------------------------------------------------------------
METHOD GetCountReg(cAlias,aChave,lQuery) Class PLSREGIC
LOCAL aArea		:= GetArea()    
LOCAL nHoraBase := Seconds()
LOCAL nI		:= 1	
LOCAL nQtd 		:= 0
LOCAL cWhile 	:= ""  
LOCAL cSql		:= ""          
DEFAULT lQuery	:= .T.
DEFAULT aChave	:= {}
//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴
//쿞e vai retornar via query
//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴
If lQuery
	//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴
	//쿞elect
	//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴
	cSql := "SELECT COUNT(R_E_C_N_O_) AS QTD FROM " +(cAlias)->( RetSQLName(cAlias) )
	cSql += " WHERE " + cAlias + "_FILIAL = '" + xFilial(cAlias) + "' "
	cSql += "   AND D_E_L_E_T_ = ' ' "  
	//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴
	//쿘onta a chave da query
	//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴
	For nI:=1 To Len(aChave)
		//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴
		//쿘onta complementos do wher
		//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴
	    If Upper(aChave[nI,2]) == 'IN'
			cSql += ' AND ' + aChave[nI,1] + " " +aChave[nI,2] + " " + StrTran(cValToChar(aChave[nI,3]),'"',"'")
	    Else
			cSql += ' AND ' + aChave[nI,1] + aChave[nI,2] + " '" + aChave[nI,3] + "' "
		EndIf	
	Next	
	//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴
	//쿐xecuta query
	//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴
	cSql := ChangeQuery(cSql)   
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cSql),"TRBDY",.T.,.T.)
	//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴
	//쿜uantidade de registos
	//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴
	nQtd := TRBDY->QTD
	//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴
	//쿑echa area
	//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴
	TRBDY->( DbCloseArea() )                                                     
Else	
	//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
	//� Monta While
	//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
	If Len(aChave) > 0
		For nI:=1 To Len(aChave)
			cWhile += aChave[nI,1] + " = '" + cValToChar(aChave[nI,3]) + "' .AND. "
		Next	
		cWhile := SubStr(cWhile,1,Len(cWhile)-6)
	EndIf	
	//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
	//� Retorna quantidade de registro
	//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
	If !Empty(cWhile)
		(cAlias)->( DbEval( {|| nQtd++ },,{|| &cWhile },,,.T. ) ) 
	Else
		(cAlias)->( DbEval( {|| nQtd++ } ) )
	EndIf	                       
EndIf	
//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴
//쿝estaura area
//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴
RestArea( aArea )
//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
//� Dura豫o
//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
_Super:SetLog(nHoraBase)
//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
//� Fim do metodo															 				   
//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
Return(nQtd)         
//-------------------------------------------------------------------
/*/ { Protheus.doc } GetDadBx3
Retorna a quantidade de registro de uma Tabela usando Query.

@author Alexander Santos
@since 02/02/11
@version 1.0
/*/
//-------------------------------------------------------------------
METHOD GetDadBx3(aDad,cOperad,cTipoAc,cCodUsuDef,cTipoRe) Class PLSREGIC
LOCAL aArea		:= GetArea()
LOCAL nHoraBase := Seconds()
LOCAL nPos  	:= 0
LOCAL cSql  	:= "" 

If PLSALIASEX("BX3")
   //旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴
   //� Selecion todos os acesso deste usuario 
   //읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴
   cSQL := " SELECT BX3_ALIAS, BX3_DATA, BX3_HORA"
   cSQL += " FROM "+BX3->( RetSQLName("BX3") )
   cSQL += " WHERE BX3_FILIAL = '"+xFilial("BX3") + "'"
   cSQL += " AND BX3_OPERAD = '" + cOperad + "'"
   cSQL += " AND BX3_TIPO   = '" + cTipoAc + "'"
   cSQL += " AND D_E_L_E_T_ = ' '"
   cSQL := ChangeQuery(cSQL)
   dbUseArea(.T.,"TOPCONN",TCGENQRY(,,cSQL),"TrbBX3",.F.,.T.)
   //旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
   //� Verifica se existe algum acesso antigo 
   //읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
   If !TrbBX3->( Eof() )
      	BX3->( DbSetOrder(1) )                                                           
      	While !TrbBX3->( Eof() )
      		//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
	   	   //� Atualiza a descricao
		   //읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
 		   If BX3->( MsSeek( xFilial("BX3") + cCodUsuDef + cTipoRe + TrbBX3->BX3_ALIAS ) ) .And. DtoS(BX3->BX3_DATA) >= TrbBX3->BX3_DATA .And. BX3->BX3_HORA > TrbBX3->BX3_HORA
			   If ( nPos := Ascan(aDad,{|x| x[1] == TrbBX3->BX3_ALIAS } ) ) > 0
				   aDad[nPos,2] := " * " + aDad[nPos,2]
			   EndIf 			
		   EndIf	 		
	   //旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
	   //� Proximo
	   //읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
	   TrbBX3->( DbSkip() )
	   EndDo
   EndIf
   //旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
   //� Fecha area de trabalho
   //읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
   TrbBX3->( DbCLoseArea() )
   //旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴
   //� Restaura area															 
   //읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴
   RestArea( aArea )       
   //旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴
   //� Dura豫o
   //읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴
Endif
_Super:SetLog(nHoraBase)
//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴커
//� Fim do metodo															 �
//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴켸
Return(aDad)         
//-------------------------------------------------------------------
/*/ { Protheus.doc } GetBx3Ace
Valida acesso de um determinado operador a uma rotina

@author Alexander Santos
@since 02/02/11
@version 1.0
/*/
//-------------------------------------------------------------------
METHOD GetBx3Ace(cAlias,cOperad) Class PLSREGIC
LOCAL aArea			:= GetArea()
LOCAL nHoraBase 	:= Seconds()
LOCAL cSql  		:= ""
LOCAL cTipoRe	 	:= '1'      
LOCAL cTipoAc	 	:= '0'
LOCAL cCodUsuDef 	:= "XXXXXX"
LOCAL lFound		:= .F.
//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴
//� Selecion todos os acesso deste usuario 
//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴
cSQL := " SELECT BX3_ALIAS, BX3_DATA, BX3_HORA"
cSQL += " FROM "+BX3->( RetSQLName("BX3") )
cSQL += " WHERE BX3_FILIAL = '"+xFilial("BX3") + "' "
cSQL += " AND BX3_OPERAD = '" + cOperad + "' "
cSQL += " AND BX3_TIPO   = '" + cTipoAc + "' "
cSQL += " AND BX3_ALIAS  = '" + cAlias + "' "
cSQL += " AND D_E_L_E_T_ = ' ' "       

cSQL := ChangeQuery(cSQL)
dbUseArea(.T.,"TOPCONN",TCGENQRY(,,cSQL),"TrbBX3",.F.,.T.)
//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
//� Verifica se existe algum acesso antigo 
//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
If !TrbBX3->( Eof() )
	BX3->( DbSetOrder(1) )                                                           
	While !TrbBX3->( Eof() )
		//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
		//� Atualiza a descricao
		//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
 		If BX3->( MsSeek( xFilial("BX3") + cCodUsuDef + cTipoRe + TrbBX3->BX3_ALIAS ) ) .And. DtoS(BX3->BX3_DATA) >= TrbBX3->BX3_DATA .And. BX3->BX3_HORA > TrbBX3->BX3_HORA
			lFound := .T.
			Exit
		EndIf	 		
	//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
	//� Proximo
	//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
	TrbBX3->( DbSkip() )
	EndDo
Else
	lFound := BX3->( MsSeek( xFilial("BX3") + cCodUsuDef + cTipoRe + cAlias ) )	
EndIf
//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
//� Fecha area de trabalho
//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
TrbBX3->( DbCLoseArea() )
//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴
//� Restaura area															 
//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴
RestArea( aArea )       
//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴
//� Dura豫o
//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴
_Super:SetLog(nHoraBase)
//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴커
//� Fim do metodo															 �
//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴켸
Return(lFound)         
//-------------------------------------------------------------------
/*/ { Protheus.doc } Destroy
Libera da memoria o obj (Destroy)

@author Alexander Santos
@since 02/02/11
@version 1.0
/*/
//-------------------------------------------------------------------
METHOD Destroy() Class PLSREGIC
FreeObj(Self:self)
Return
/*/
複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複
굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇
굇旼컴컴컴컴컫컴컴컴컴컴쩡컴컴컴쩡컴컴컴컴컴컴컴컴컴컴컴쩡컴컴컫컴컴컴컴컴엽굇
굇쿑uncao    쿛LSREGIC  � Autor � Totvs				    � Data � 30/03/10 낢굇
굇쳐컴컴컴컴컵컴컴컴컴컴좔컴컴컴좔컴컴컴컴컴컴컴컴컴컴컴좔컴컴컨컴컴컴컴컴눙굇
굇쿏escricao � Somente para compilar a class							  낢굇
굇읕컴컴컴컴컨컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴袂굇
굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇
賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽
/*/
Function PLSREGIC
Return
