#Include 'Totvs.ch' 
#Include 'Protheus.ch'
//---------------------------------------------------------------------
/*/{Protheus.doc} ExtSlcLay

Browse para marcação dos layouts a serem processados via schedule

@Author	Henrique Pereira 
@Since		02/04/2020
@Version	1.0
/*/
//---------------------------------------------------------------------
function ExtSlcLay(cOpenBrw, cFiltReinf)   

Local oBrowse       :=  Nil
Local cCadastro     :=  "Layouts para extração" 
Local cAlias        :=  "V5M"
Local oDlg          :=  nil 
Local aFildsShow    :=  {}
Local bok	        :=	{||oDlg:End()}
Local nTop		    :=	0
Local nLeft	    	:=	0  
Local aSize	    	:=	FWGetDialogSize( oMainWnd )
Local lAlsV5M       :=  AliasInDic('V5M')

Default cOpenBrw    :=  '1'  
Default cFiltReinf  :=  ''    
 
    if lAlsV5M .and. cValToChar(cOpenBrw) == '1' .and. cValToChar(cFiltReinf) == '2' 

        oDlg := MsDialog():New( nTop, nLeft, aSize[3], aSize[4], cCadastro,,,,,,,,, .T.,,,, .F. )

        CountTable()
        aFildsShow  := (cAlias)->( DBStruct() )  

        oBrowse:= FWMarkBrowse():New() 
        oBrowse:SetOwner( oDlg )
        oBrowse:SetDescription(cCadastro) //Titulo da Janela   
        oBrowse:SetDataTable()
        oBrowse:SetAlias("V5M") //Indica o alias da tabela que serÃ¡ utilizada no Browse
        oBrowse:SetCustomMarkRec( { || FMark( oBrowse ) } )   
        oBrowse:SetAllMark( { || FMarkAll( oBrowse ) } )	
       
        oBrowse:SetFieldMark("V5M_MARKED") //Indica o campo que deverÃ¡ ser atualizado com a marca no registro
        oBrowse:oBrowse:SetFixedBrowse(.T.)
        oBrowse:SetWalkThru(.F.) //Habilita a utilizaÃ§Ã£o da funcionalidade Walk-Thru no Browse
        oBrowse:SetMenuDef( "" )
        oBrowse:DisableReport()
        oBrowse:DisableConfig()
        oBrowse:SetAmbiente( .F. )    
        oBrowse:oBrowse:SetFilterDefault("") //Indica o filtro padrÃ£o do Browse
        oBrowse:DisableDetails()           
        oBrowse:AddButton( "Confirmar", bok ) //"Confirmar"
        oBrowse:Activate()
        FOpenMark( oBrowse )
        oBrowse:Refresh()
        oDlg:Activate()
    endif 
    
Return(.T.)

//---------------------------------------------------------------------
/*/{Protheus.doc} FMark

Executa a gravação do retorno da Consulta Específica.

@Param		oBrowse	- Objeto da Browse
			cReadVar	- Campo de retorno da Consulta Específica
			cChave		- Campo(s) a serem gravados no retorno da Consulta Específica
			lMult		- Indica se a tela permição selec de múltiplos registros

@Author	Henrique Pereira 
@Since		02/04/2020
@Version	1.0
/*/
//---------------------------------------------------------------------
 
static function FMark(oBrowse)
Local cAlias	:=	oBrowse:Alias()
Local cMark	    :=	oBrowse:Mark()
    If RecLock( cAlias, .F. )
		( cAlias )->V5M_MARKED := Iif( ( cAlias )->V5M_MARKED == cMark, "  ", cMark )
		( cAlias )->( MsUnlock() )
	EndIf  

Return 



Return 

//---------------------------------------------------------------------
/*/{Protheus.doc} FOpenMark

Inverte a indicação de seleção de todos registros do Browse.

@Param		oBrowse	->	Objeto contendo campo de seleção

@Return	Nil

/*/
//---------------------------------------------------------------------
Static Function FOpenMark( oBrowse )

Local cAlias	as character
Local cMark	    as character

cAlias	:=	oBrowse:Alias()
cMark	:=	oBrowse:Mark()


( cAlias )->( DBGoTop() )

While ( cAlias )->( !Eof() )

	If RecLock( cAlias, .F. ) .and.  (V5M->(MsSeek(XFilial('V5M')+(cAlias)->V5M_LAYOUT) ))       
	    ( cAlias )->V5M_MARKED := Iif(Empty(V5M->V5M_MARKED), "  ", cMark )
		( cAlias )->( MsUnlock() ) 
	EndIf

	( cAlias )->( DBSkip() )
EndDo
oBrowse:Refresh()

Return()

//---------------------------------------------------------------------
/*/{Protheus.doc} FMarkAll

Inverte a indicação de seleção de todos registros do Browse.

@Param		oBrowse	->	Objeto contendo campo de seleção

@Return	Nil

/*/
//---------------------------------------------------------------------
Static Function FMarkAll( oBrowse )

Local cAlias	as character
Local cMark	    as character
Local nRecno	as numeric

cAlias	:=	oBrowse:Alias()
cMark	:=	oBrowse:Mark()
nRecno	:=	( cAlias )->( Recno() )


( cAlias )->( DBGoTop() )

While ( cAlias )->( !Eof() )

	If RecLock( cAlias, .F. )
		( cAlias )->V5M_MARKED := Iif( alltrim(( cAlias )->V5M_MARKED) == cMark, "  ", cMark )
		( cAlias )->( MsUnlock() ) 
	EndIf

	( cAlias )->( DBSkip() )
EndDo

( cAlias )->( DBGoTo( nRecno ) )

oBrowse:Refresh()

Return()

//---------------------------------------------------------------------
/*/{Protheus.doc} CountTable

Alimenta a tabela V5M se a quantidade de registros nela for diferente 
do retornado por fLayouts

@Author	Henrique Pereira 
@Since		02/04/2020
@Version	1.0
/*/
//---------------------------------------------------------------------

static function CountTable()

Local cAlias        :=  "V5M"    
Local cAlsQuery     :=  GetNextAlias()
Local aLayouts      :=  fLayouts()
Local nCountLay     :=  len(aLayouts)
Local nLayOut       :=  0

    BeginSql Alias cAlsQuery   
        SELECT COUNT(R_E_C_N_O_) COUNT  
        FROM %Table:V5M% V5M
        WHERE V5M.V5M_FILIAL = %xfilial:V5M%
            AND V5M.%notDel%
    ENDSQL
   
    if (cAlsQuery)->COUNT <> nCountLay
        
        if nCountLay > 0
            TcSqlExec("DELETE FROM " + RetSqlName(cAlias))
        endif 
       
        DbSelectArea(cAlias)
        (cAlias)->(DbSetOrder(1)) 
        for nLayOut := 1 to nCountLay
            RecLock(cAlias,.T.)
            (cAlias)->V5M_LAYOUT       := aLayouts[nLayOut][2]
            (cAlias)->V5M_DESCRI       := aLayouts[nLayOut][3]
            (cAlias)->V5M_PERIOD       := aLayouts[nLayOut][4]
        next nLayOut 

    endif

    (cAlsQuery)->(DbCloseArea())

return