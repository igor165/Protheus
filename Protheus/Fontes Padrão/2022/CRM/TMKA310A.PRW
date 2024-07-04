#INCLUDE "TMKA310A.CH"  
#INCLUDE "PROTHEUS.CH"    
#INCLUDE "FWMVCDEF.CH"  

//------------------------------------------------------------------- -----------
/*/{Protheus.doc} TMKA310A 

Chamada do browse de lista de marketing/contatos.

@sample		TMKA310A()

@param			Nenhum

@return		Nenhum

@author		Cristiane Nishizaka
@since			08/04/2014
@version		12.0
/*/
//------------------------------------------------------------------------------

Function TMKA310A(cAlias, nRecNo)

Local aArea		:= GetArea()
Local aListMark	:= {} 
Local aListOrig	:= {}
Local aDados		:= {}
Local aCampos		:= {}
Local nI			:= 0
Local cFiltro 		:= "" 
Local cFilAO4		:= ""
Local cTitle		:= ""
Local lFiltroCRM	:= .F. 

Local bMark		:= {|| Iif((nPos := aScan(aListMark, SU4->U4_LISTA)) == 0, aAdd(aListMark, SU4->U4_LISTA), (aDel(aListMark, nPos), aSize(aListMark, Len(aListMark)-1))) } 
Local bMarkAll	:= {|oBrowse| Iif(Len(aListMark) > 0, aListMark := {}, aListMark := Tk310AGetAll()), oBrowse:Refresh() }

Default cAlias		:= Alias()
Default nRecNo		:= ( cAlias )->( RecNo() )

If nModulo == 73
	cFiltro		:= "!Empty(SU4->U4_ENTIDA)"
	cFilAO4		:= CRMXFilEnt("SU4",.T.)
	lFiltroCRM	:= .T.
Else
	cFiltro := "Empty(SU4->U4_ENTIDA)"
EndIf

// Cria array com a estrutura da tabela de listas de marketing
aDados		:= Tk310ACpBrw( "SU4" )
aCampos	:= aDados[2] // cCampo, X3Titulo(),SX3->X3_TIPO, SX3->X3_TAMANHO, SX3->X3_DECIMAL,X3CBox()

DbSelectArea("SUO")
DbSetOrder(1) //UO_FILIAL+UO_CODCAMP
SUO->(DbGoTo(nRecNo))

cChvCamp := xFilial("SUO")+SUO->UO_CODCAMP

// Filtra as listas da campanha na tabela de Membros da Campanha
DbSelectArea("AOG")
AOG->(DbSetOrder(2)) //AOG_FILIAL+AOG_CHVCAM+AOG_TIPCAM
AOG->(DbGoTop())

If AOG->(DbSeek(xFilial("AOG")+PadR(cChvCamp,Len(AOG_CHVCAM))+"1"))
	While AOG->(!EOF()) .And. PadR(cChvCamp,Len(AOG_CHVCAM)) == AOG->AOG_CHVCAM .And. AOG->AOG_TIPCAM == "1"
		If aScan(aListMark,SubStr(AOG->AOG_CHVLST,Len(AOG_FILIAL)+1,6)) == 0
			Aadd(aListMark,SubStr(AOG->AOG_CHVLST,Len(AOG_FILIAL)+1,6))
		EndIf
		AOG->(DbSkip())
	EndDo
EndIf

// Guarda as listas utilizadas na campanhas antes da alteração
If Len(aListMark) > 0
	aListOrig := aClone(aListMark)
EndIf

If nModulo == 73
	cTitle := STR0001 //"Listas de Marketing"
Else
	cTitle := STR0002 //"Listas de Contatos"
EndIf

DEFINE DIALOG oDlg TITLE cTitle FROM 0,0 TO 500,800 PIXEL   

	DEFINE FWBROWSE oBrowse DATA TABLE ALIAS "SU4" OF oDlg
	
		ADD MARKCOLUMN oColumn DATA { || Iif(aScan(aListMark, SU4->U4_LISTA) == 0, 'LBNO', 'LBOK' ) } DOUBLECLICK bMark HEADERCLICK bMarkAll OF oBrowse
		For nI := 1 To Len(aCampos)
			ADD COLUMN oColumn DATA &("{ ||" + aCampos[nI][1] + " }") TITLE aCampos[nI][2] SIZE aCampos[nI][4] OF oBrowse
		Next nI
		
		oBrowse:SetFilterDefault( cFiltro )
		oBrowse:SetUseFilter()  

		If lFiltroCRM  
			If !Empty(cFilAO4) 
				oBrowse:AddFilter(STR0003, cFilAO4, .T., .T., "AO4", , , "AO4_FILENT" ) //"Filtro do CRM" 
				oBrowse:ExecuteFilter() 
			EndIf
		EndIf
	
	ACTIVATE FWBROWSE oBrowse
	
//Bloco a ser executado ao "Confirmar" a tela -> <CTRL+O>
bSetConf := { || lConfirm := .T., GetKeys(), SetKey( VK_F3, Nil ), Tk310AEntGet( aListMark, "SU4", aListOrig, cChvCamp ), oDlg:End() }

//Bloco a ser executado ao "Finalizar" a tela -> <CTRL+X>
bSetFech := { || lConfirm := .F. ,GetKeys(), SetKey( VK_F3, Nil ), oDlg:End() }  

//Habilitação da EnchoiceBar
bInitBr  := { || EnchoiceBar( oDlg, bSetConf, bSetFech, Nil ) }
oDlg:bInit := bInitBr

ACTIVATE DIALOG oDlg CENTERED   

SU4->( dbClearFilter() )

RestArea( aArea )

Return


//-------------------------------------------------------------------------
/*/{Protheus.doc} Tk310AGetAll

Marca/Desmarca Todos.

@sample 		Tk310AGetAll()

@param   		Nenhum

@return		aListMark		Array com todas as listas

@author		Cristiane Nishizaka
@since			08/04/2014
@version		12.0
/*/
//-------------------------------------------------------------------------

Static Function Tk310AGetAll()

Local aListMark 	:= {}
Local aArea		:= GetArea()

DbSelectArea("SU4")
SU4->(DbSetOrder(1)) // U4_FILIAL+U4_LISTA+DTOS(U4_DATA)

While SU4->(!Eof())
	aAdd(aListMark,SU4->U4_LISTA)
	SU4->(DbSkip())
EndDo

RestArea( aArea )

Return aListMark


//-------------------------------------------------------------------------
/*/{Protheus.doc} Tk310ACpBrw

Função que seleciona a estrutura da tabela

@sample 		Tk310ACpBrw( cEntidad )

@param   		cEntidad		Alias da entidade 

@author		Cristiane Nishizaka
@since			08/04/2014
@version		12.0
/*/
//-------------------------------------------------------------------------

Function Tk310ACpBrw( cEntidad )

Local aArea       := GetArea()
Local aCampos     := {}
Local aStruct	  := {}
Local cCampo      := ""
Local cCpoQry 	  := ""

DbSelectArea( "SX3" )
DbSetOrder( 1 )

If Dbseek( cEntidad )

       While !SX3->( Eof() ) .AND. SX3->X3_ARQUIVO == cEntidad
             cCampo := AllTrim( SX3->X3_CAMPO )
             If ( X3USO( SX3->X3_USADO ) .AND. SX3->X3_BROWSE == "S" .AND. SX3->X3_CONTEXT <> "V" .AND. SX3->X3_TIPO <> "M ")
                    AAdd( aCampos,{ cCampo, X3Titulo(),SX3->X3_TIPO, SX3->X3_TAMANHO, SX3->X3_DECIMAL,X3CBox() } )
                    AAdd( aStruct,{ cCampo,SX3->X3_TIPO, SX3->X3_TAMANHO, SX3->X3_DECIMAL } )
                    cCpoQry += cCampo+", "
             EndIf
             SX3->( DbSkip() )
       End
       cCpoQry := "%"+AllTrim( Padr( cCpoQry, Len( cCpoQry ) -2 ) ) +"%"   
EndIf

RestArea( aArea )

Return( { aStruct, aCampos, cCpoQry } ) 


//-------------------------------------------------------------------------
/*/{Protheus.doc} Tk310AEntGet

Adiciona os registros selecionados na tabela de Membros da Campanha

@sample 		Tk310AEntGet( aLista, cEntidad, aListOrig, cChvCamp )
       
@param   		aLista			Lista os registros selecionados
				cEntidad		Alias da Entidade
				aListOrig		Lista atual de membros
				cChvCamp		Chave da Campanha

@return  		lRet		.T. Gravou
							.F. Não gravou

@author		Cristiane Nishizaka
@since			08/04/2014
@version		12.0
/*/
//-------------------------------------------------------------------------

Static Function Tk310AEntGet( aLista, cEntidad, aListOrig, cChvCamp )    

Local aArea 		:= GetArea()
Local aAreaAOG 	:= AOG->(GetArea())
Local nLista		:= 0  
Local lRet			:= .F.
Local aChvEnt		:= {}
Local aChvLst		:= {}
Local aChvCamp	:= {}
Local aLstExc		:= {}
Local nX			:= 0
Local nI			:= 0

Default aLista 	:= {}                                                    
Default cEntidad	:= "" 

For nX := 1 To Len(aListOrig)
	// Compara os arrays, se alguma das listas atuais da campanha (aListOrig)
	// não estiver entre as listas a serem incluidas (aLista),
	// guarda no array aLstExc para excluí-las da tabela AOG
	If (aScan(aLista, aListOrig[nX]) == 0)
		aAdd(aLstExc,aListOrig[nX])
	EndIf
Next nX

If Len(aLstExc) >0
	For nI := 1 To Len(aLstExc)
		DbSelectArea("AOG")
		AOG->(DbSetOrder(3)) // AOG_FILIAL+AOG_CHVLST+AOG_CHAVE+AOG_CHVCAM+AOG_TIPCAM
		// Obtem o X2_UNICO da lista
		aChvLst	:=	Tk310AChv("SU4", aLstExc[nI])		
		// Executa a deleção das listas da campanha		
		If AOG->(DbSeek(xFilial("AOG")+aChvLst[1]))
			While AOG->(!EOF()) .And. SubStr(AOG->AOG_CHVLST,Len(AOG->AOG_FILIAL)+1,6) == aLstExc[nI]
				RecLock("AOG",.F.)
					DbDelete()
				AOG->(MsUnlock())
				AOG->(DbSkip())
			EndDo
		EndIf
	Next nI
EndIf

// Executa a atualização das listas da campanha na AOG
DbSelectArea("SU6")
SU6->(DbSetOrder(1)) // U6_FILIAL+U6_LISTA+U6_CODIGO

For nLista := 1 To Len( aLista )
	If SU6->(DbSeek(xFilial("SU6")+aLista[nLista]))
		While !Eof() .And. SU6->U6_FILIAL == xFilial("SU6") .And. SU6->U6_LISTA == aLista[nLista]		
			// Obtem as informações de outras tabelas para adicionar na AOG
			aChvEnt	:= 	Tk310AChv(	Iif(!Empty(SU6->U6_ENTIDA) .And. !Empty(SU6->U6_CONTATO),"SU5",SU6->U6_ENTIDA),;
										Iif(Empty(Posicione("SU4",1,xFilial("SU4")+SU6->U6_LISTA,"U4_ENTIDA")) .Or. Empty(SU6->U6_CODENT),AllTrim(SU6->U6_CONTATO),AllTrim(SU6->U6_CODENT)))
			aChvLst	:=	Tk310AChv("SU4", SU6->U6_LISTA)
			aChvCamp	:=	Tk310AChv("SUO", SubStr(cChvCamp,Len(xFilial("SUO"))+1,6))
			If Len(aChvEnt) > 0 .And. Len(aChvLst) > 0 .And. Len(aChvCamp) > 0
				DbSelectArea("AOG")
				AOG->(DbSetOrder(3)) // AOG_FILIAL+AOG_CHVLST+AOG_CHAVE+AOG_CHVCAM+AOG_TIPCAM
				If !AOG->(DbSeek(xFilial("AOG")+PadR(aChvLst[1],Len(AOG->AOG_CHVLST))+PadR(aChvEnt[1],Len(AOG->AOG_CHAVE))+PadR(aChvCamp[1],Len(AOG->AOG_CHVCAM))+"1"));
					.And. !Empty(aChvEnt[1]) .And. !Empty(aChvLst[1]) .And. !Empty(aChvCamp[1])
					If RecLock("AOG",.T.)
							AOG->AOG_FILIAL 	:=	xFilial("AOG")	
							AOG->AOG_CODIGO 	:=	GETSXENUM("AOG","AOG_CODIGO")
							AOG->AOG_ENTIDA 	:=	Iif(!Empty(SU6->U6_ENTIDA) .And. !Empty(SU6->U6_CONTATO),"SU5",SU6->U6_ENTIDA)
							AOG->AOG_CHAVE  	:= 	aChvEnt[1]
							AOG->AOG_CHVLST 	:= 	aChvLst[1]
							AOG->AOG_TIPCAM 	:=	"1"
							AOG->AOG_CHVCAM 	:=	aChvCamp[1]
						AOG->(MsUnlock())		
						ConfirmSX8()		
					Else
						lRet := .F.
						While GetSx8Len() > nLenSX8
							RollBackSX8()
						EndDo
					EndIf			
					//Atualiza a data da última utilização da lista de Marketing
					TK61DtList( SU6->U6_LISTA )
				EndIf
			Endif
			SU6->(DbSkip())
		End
	EndIf
Next( nLista )

RestArea(aAreaAOG)
RestArea(aArea)

Return( lRet )      

//------------------------------------------------------------------------------
/*/{Protheus.doc} Tk310AChv

Busca X2_UNICO.

@sample		Tk310AChv(cAliasName, cAuxBusca)

@param			cAliasName		Alias
				cAuxBusca		Chave
				
@return		aRet 			Array contendo o X2_UNICO e a Descrição da entidade

@author		Cristiane Nishizaka
@since			07/02/2014
@version		12.0
/*/
//------------------------------------------------------------------------------

Function Tk310AChv(cAliasName, cAuxBusca)

Local aRet			:= 	{} 
Local cRetDesc	:=	""
Local cRetUnico	:=	""
Local aGetSx2		:= 	{}

aGetSx2	:= CRMXGetSX2(cAliasName)

DbSelectArea(cAliasName)
(cAliasName)->(DbSetOrder(1))

If (cAliasName)->(DbSeek(xFilial(cAliasName)+cAuxBusca))
	// obtem o X2_UNICO da entidade
	cRetUnico := &(aGetSx2[1])	
	// Seta a descrição da entidade
	Do Case 
		Case cAliasName == "SA1"
			cRetDesc 	:= SA1->A1_NOME
		Case cAliasName == "SUS"
			cRetDesc	:= SUS->US_NOME
		Case cAliasName == "SU5"
			cRetDesc	:= SU5->U5_CONTAT
		Case cAliasName == "ACH"
			cRetDesc	:= ACH->ACH_RAZAO
		Case cAliasName == "SU4"
			cRetDesc	:= SU4->U4_DESC
		Case cAliasName == "SUO"
			cRetDesc	:= SUO->UO_DESC
	EndCase
	
	If !Empty(cRetUnico)
		cRetUnico := xFilial(cAliasName)+cRetUnico // Adiciona a filial
		aAdd(aRet,cRetUnico)
		aAdd(aRet,cRetDesc)
	EndIf
	
EndIf

Return (aRet)


//------------------------------------------------------------------------------
/*/{Protheus.doc} Tk310DsEnt

Retorna a descrição da entidade.

@sample		Tk310DsEnt()

@param			Nenhum

@return		cRetDesc	Descrição

@author		Cristiane Nishizaka
@since			19/05/2014
@version		12.0
/*/
//------------------------------------------------------------------------------

Function Tk310DsEnt()

Local aArea  		:= GetArea()   	// Salva a area atual
Local aAreaAlias	:= {}				// Salva area da tabela SC6
Local cRetDesc 	:= ""
Local cCamp		:= ""
Local cEnt			:= ""

cEnt	:= AOG->AOG_ENTIDA

DbSelectArea(cEnt)
(cEnt)->(DbSetOrder(1))

aAreaAlias	:= (cEnt)->(GetArea())

Do Case
	Case AOG->AOG_ENTIDA == "SA1" // Clientes
		cCamp := "A1_NOME"
	Case AOG->AOG_ENTIDA == "SUS" // Prospects
		cCamp := "US_NOME"
	Case AOG->AOG_ENTIDA == "ACH" // Suspects
		cCamp := "ACH_RAZAO"
	Case AOG->AOG_ENTIDA == "SU5" // Contatos 
		cCamp := "U5_CONTAT"
End Case

If (cEnt)->(DbSeek(AOG->AOG_CHAVE))

	cRetDesc := &((cEnt)->(cCamp))

EndIf
 
RestArea(aArea)	
RestArea(aAreaAlias)	
 
Return cRetDesc


//------------------------------------------------------------------------------
/*/{Protheus.doc} Tk310AUpdAOG

Atualiza os membros da Campanha de acordo com a alteração da lista de marketing.

@sample		Tk310AUpdAOG(aLista, lUpd, cLista, cEntid)

@param			aLista 		Array da AO6
				lUpd		.T. Insere membros
							.F. Deleta membros
				cLista		Código da lista
				cEntid		Alias Entidade

@return		Nenhum

@author		Cristiane Nishizaka
@since			07/02/2014
@version		12.0
/*/
//------------------------------------------------------------------------------

Function Tk310AUpdAOG(aLista, lUpd, cLista, cEntid)

Local aArea 		:= GetArea()
Local aAreaAOG 	:= AOG->(GetArea())
Local nLista		:= 0  
Local aChvEnt		:= {}
Local aChvLst		:= {}
Local aChvCamp	:= {}
Local aCampanha	:= {}
Local nCamp		:= {}
Local cChvLst		:= ""

DbSelectArea("AOG")
AOG->(DbSetOrder(3)) // AOG_FILIAL+AOG_CHVLST+AOG_CHAVE+AOG_CHVCAM+AOG_TIPCAM
AOG->(DbGoTop())

If Len(aLista) > 0 

	aChvLst	:=	Tk310AChv("SU4", cLista)
	cChvLst := aChvLst[1]
	// Busca todas as campanhas que utilizam a lista alterada
	If AOG->(DbSeek(xFilial("AOG")+cChvLst))
		While AOG->(!EOF()) 
			If AOG->AOG_CHVLST == PadR(cChvLst,Len(AOG->AOG_CHVLST)) .And. AOG->AOG_TIPCAM == "1" // se for do tipo 1 = Campanha
				If aScan(aCampanha,AOG->AOG_CHVCAM) == 0
				 	aAdd(aCampanha,AOG->AOG_CHVCAM)
				EndIf
			EndIf
			AOG->(DbSkip())
		EndDo
	EndIf
	
	If Len(aCampanha) > 0
		For nCamp := 1 To Len (aCampanha)
			For nLista := 1 To Len( aLista )		
				// Obtem as informações de outras tabelas para adicionar na AOG
				aChvEnt	:= 	Tk310AChv(cEntid,AllTrim(aLista[nLista][7]))
				aChvLst	:=	Tk310AChv("SU4", cLista)
				aChvCamp	:=	Tk310AChv("SUO", Right(Alltrim(aCampanha[nCamp]),TAMSX3("UO_CODCAMP")[1]))	
				DbSelectArea("AOG")
				AOG->(DbSetOrder(3)) // AOG_FILIAL+AOG_CHVLST+AOG_CHAVE+AOG_CHVCAM+AOG_TIPCAM
				If lUpd .And. !AOG->(DbSeek(xFilial("AOG")+PadR(aChvLst[1],Len(AOG->AOG_CHVLST))+PadR(aChvEnt[1],Len(AOG->AOG_CHAVE))+PadR(aChvCamp[1],Len(AOG->AOG_CHVCAM))+"1"))
					If RecLock("AOG",.T.)
							AOG->AOG_FILIAL 	:=	xFilial("AOG")
							AOG->AOG_CODIGO 	:=	GETSXENUM("AOG","AOG_CODIGO")
							AOG->AOG_ENTIDA 	:=	cEntid
							AOG->AOG_CHAVE  	:= 	aChvEnt[1]
							AOG->AOG_CHVLST 	:= 	aChvLst[1]
							AOG->AOG_TIPCAM 	:=	"1"
							AOG->AOG_CHVCAM 	:=	aChvCamp[1]
						AOG->(MsUnlock())		
						ConfirmSX8()		
					Else
						lRet := .F.
						While GetSx8Len() > nLenSX8
							RollBackSX8()
						EndDo
					EndIf	
					//Atualiza a data da última utilização da lista de Marketing
					TK61DtList( cLista )
				ElseIf !lUpd .And. AOG->(DbSeek(xFilial("AOG")+PadR(aChvLst[1],Len(AOG->AOG_CHVLST))+PadR(aChvEnt[1],Len(AOG->AOG_CHAVE))+PadR(aChvCamp[1],Len(AOG->AOG_CHVCAM))+"1"))
					RecLock("AOG",.F.)
					DbDelete()
					AOG->(MsUnlock())
				EndIf	
			Next( nLista )
			nLista := 0
		Next ( nCamp )
	EndIf

EndIf 

RestArea(aAreaAOG)
RestArea(aArea)

Return
