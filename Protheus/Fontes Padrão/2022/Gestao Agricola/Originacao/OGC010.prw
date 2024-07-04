#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "FWCALENDARWIDGET.CH"
#INCLUDE "OGC010.CH"

/*{Protheus.doc} OGC010
(Rotina para Consulta da Necessidade de Reserva)
@type function
@author roney.maia
@since 20/03/2017
@version 1.0
*/
Function OGC010()
	
	Local aArea			:= GetArea()
	Private _oMBrowse 	:= Nil
	Private _cPergunte 	:= "OGC0100001"
	Private _aLegenda 	:= {}
	Private _oExtGet	:= NIL
	Private _oInttGet	:= NIL
	Private _lFirst		:= .F.
	Private _oDlg		:= NIL
	Private _oCalend 	:= Nil
	Private _oPnCalend	:= Nil
	Private _oPnCampsE	:= Nil
	Private _oPnCampsI	:= Nil
	Private _dDataAgd	:= STOD("")
	Private _dData		:= STOD("")
	Private _cHora		:= Space(5)
	Private _cClassExt	:= If( ColumnPos( 'DXP_CLAEXT' ) > 0 , Space(TamSx3("DXP_CLAEXT")[1])	, "")
	Private _cClassInt	:= If( ColumnPos( 'DXP_CLAINT' ) > 0 , Space(TamSx3("DXP_CLAINT")[1])	, "")
	Private _cNomExt	:= If( ColumnPos( 'NNA_NOME' ) > 0	 , Space(TamSx3("NNA_NOME")[1])		, "")
	Private _cNomInt	:= If( ColumnPos( 'NNA_NOME' ) > 0   , Space(TamSx3("NNA_NOME")[1])		, "")
	Private _aFieldsTm	:= {} // Array com os campos que serao utilizados pelo Filtro - FwFilter
	Private _cResInc	:= ""
	Private _lOgc010Ag 	:= .T.
	Private _lOgc010Re 	:= .T.
	Private _oOgc010Tm	:= Nil
	Private _cAliasBrw	:= GetNextAlias() // Obtem o proximo alias disponivel, tabela temporaria
	Private _aFields	:= {}
	
	SetKey( VK_F12, { || OGC010INI() } )
	
	//-- Proteção de Código - Se parametro não existe realiza a validação.
	If !(SuperGetMv('MV_AGRA001', , .F.))
		Help(" ",1,"OGC010AGRA001") //O parâmetro MV_AGRA001(Novo Conceito UBA) está desativado.
		RestArea(aArea)
		Return(.F.)
	Endif

	_oMBrowse := FWMBrowse():New()
	OGC010NNY() // Função responsável por montar o browse
	_oMBrowse:Activate()
	
	If _oOgc010Tm != Nil // Apaga a tabela temporaria e fecha o alias
		_oOgc010Tm::Delete()
	EndIf
	
	RestArea(aArea)
Return

/*{Protheus.doc} MenuDef
(Menu da Rotina: Necessidade de Reserva)
@type function
@author roney.maia
@since 20/03/2017
@version 1.0
@return ${aRotina}, ${Array com menus}
*/
Static Function MenuDef()

	Local aRotina 	:= {}

	aAdd( aRotina, { STR0047, "OGC10RES"  , 0, 4, 0, NIL } ) // #Reservar
	aAdd( aRotina, { STR0020, "OGC010EXV" , 0, 4, 0, NIL } ) // #Agendar Take-up
    aAdd( aRotina, { STR0067, "OGC010LOG" , 0, 4, 0, Nil } )  //#Historico

Return aRotina

/*{Protheus.doc} OGC010NNY
(Função que inicializa e monta o Browse de consulta)
@type function
@author roney.maia
@since 20/03/2017
@version 1.0
*/
Static Function OGC010NNY()

	Local aColumns		:= {}
	Local nX			:= 0
	Local aFldBrw		:= {}
	Local aBrwFtr		:= {}
	Local nAuxTam		:= 0.40   // Indica que irei utilizar 40 % to tamanho definido no x3_tamanho para as colunas n. ficarem muito grandes
	Local cQuery		:= OGC010QRY(.F.) // Monta a Query para o Browse
	
	Local aIndice		:= { {"01" , {"NNY_DTLTKP"}}, {"02" , {"NNY_CODCTR"}} }
	Local nIt			:= 0

	//Define as colunas do Browse de Acordo com SX3 Para Buscar Tamanho,decimais Etc;
	aFldBrw := { /* 1 */ {AgrTitulo("NNY_CODCTR") , "NNY_CODCTR"	, TamSX3( "NNY_CODCTR" )[3]	, TamSX3( "NNY_CODCTR" )[1]	, TamSX3( "NNY_CODCTR" )[2]	, PesqPict("NNY","NNY_CODCTR") 	},;
				 /* 2 */ {AgrTitulo("NNY_ITEM")   , "NNY_ITEM"		, TamSX3( "NNY_ITEM" )[3]	, TamSX3( "NNY_ITEM" )[1]	, TamSX3( "NNY_ITEM" )[2]	, PesqPict("NNY","NNY_ITEM") 	},;
				 /* 3 */ {STR0046 				  , "DXP_CODIGO"	, TamSX3( "DXP_CODIGO" )[3]	, TamSX3( "DXP_CODIGO" )[1]	, TamSX3( "DXP_CODIGO" )[2]	, PesqPict("DXP","DXP_CODIGO") 	},;	
				 /* 4 */ {STR0083				  , "DXP_DESRES"	, TamSX3( "DXP_DESRES" )[3]	, TamSX3( "DXP_DESRES" )[1]	, TamSX3( "DXP_DESRES" )[2]	, PesqPict("DXP","DXP_DESRES") 	},;
				 /* 5 */ {STR0003				  , "NNY_DATINI"	, TamSX3( "NNY_DATINI" )[3]	, TamSX3( "NNY_DATINI" )[1]	, TamSX3( "NNY_DATINI" )[2]	, PesqPict("NNY","NNY_DATINI") 	},;
				 /* 6 */ {STR0004				  , "NNY_DATFIM"	, TamSX3( "NNY_DATFIM" )[3]	, TamSX3( "NNY_DATFIM" )[1]	, TamSX3( "NNY_DATFIM" )[2]	, PesqPict("NNY","NNY_DATFIM") 	},;
				 /* 7 */ {AgrTitulo("NJR_TKPFIS") , "NJR_TKPFIS"	, "C"						, 3							, 0							, "@!" 							},;	
				 /* 8 */ {AgrTitulo("NNY_DTLTKP") , "NNY_DTLTKP"	, TamSX3( "NNY_DTLTKP" )[3]	, TamSX3( "NNY_DTLTKP" )[1]	, TamSX3( "NNY_DTLTKP" )[2]	, PesqPict("NNY","NNY_DTLTKP") 	},;
				 /* 9 */ {STR0006   			  , "NJ0_NOME"		, TamSX3( "NJ0_NOME" )[3]	, TamSX3( "NJ0_NOME" )[1]	, TamSX3( "NJ0_NOME" )[2]	, PesqPict("NJ0","NJ0_NOME") 	},;
				 /* 10 */{AgrTitulo("NJR_CTREXT") , "NJR_CTREXT"	, TamSX3( "NJR_CTREXT" )[3]	, TamSX3( "NJR_CTREXT" )[1]	, TamSX3( "NJR_CTREXT" )[2]	, PesqPict("NJR","NJR_CTREXT") 	},;
				 /* 11 */{STR0007 				  , "NNY_QTDINT"	, TamSX3( "NNY_QTDINT" )[3]	, TamSX3( "NNY_QTDINT" )[1]	, TamSX3( "NNY_QTDINT" )[2]	, PesqPict("NNY","NNY_QTDINT") 	},;
				 /* 12 */{STR0056				  , "NNY_TKPQTD"	, TamSX3( "NNY_TKPQTD" )[3]	, TamSX3( "NNY_TKPQTD" )[1]	, TamSX3( "NNY_TKPQTD" )[2]	, PesqPict("NNY","NNY_TKPQTD") 	},;
				 /* 13 */{STR0054 				  , "DXQ_PSLIQU"	, TamSX3( "DXQ_PSLIQU" )[3]	, TamSX3( "DXQ_PSLIQU" )[1]	, TamSX3( "DXQ_PSLIQU" )[2]	, PesqPict("DXQ","DXQ_PSLIQU") 	},;
				 /* 14 */{AgrTitulo("NJR_TIPALG") , "NJR_TIPALG"	, TamSX3( "NJR_TIPALG" )[3]	, TamSX3( "NJR_TIPALG" )[1]	, TamSX3( "NJR_TIPALG" )[2]	, PesqPict("NJR","NJR_TIPALG") 	},; 
				 /* 15 */{STR0009  				  , "DXQ_BLOCO"		, "N"						, 6							, 0							, "@E 999999" 					},; 
				 /* 16 */{AgrTitulo("DXP_DATTKP") , "DXP_DATTKP"	, TamSX3( "DXP_DATTKP" )[3]	, TamSX3( "DXP_DATTKP" )[1]	, TamSX3( "DXP_DATTKP" )[2]	, PesqPict("DXQ","DXP_DATTKP") 	},;
				 /* 17 */{AgrTitulo("NJR_CODENT") , "NJR_CODENT"	, TamSX3( "NJR_CODENT" )[3]	, TamSX3( "NJR_CODENT" )[1]	, TamSX3( "NJR_CODENT" )[2]	, PesqPict("NJR","NJR_CODENT") 	},;
				 /* 18 */{AgrTitulo("NJR_LOJENT") , "NJR_LOJENT"	, TamSX3( "NJR_LOJENT" )[3]	, TamSX3( "NJR_LOJENT" )[1]	, TamSX3( "NJR_LOJENT" )[2]	, PesqPict("NJR","NJR_LOJENT") 	}}
	
	// Adição de filtro para colunas especiais	# CASO ATUALIZAR O FLDBRW ATUALIZAR AS POSICOES ABAIXO DE FILTRO #		 
	aAdd(aBrwFtr, {"OGC010CLS('DIAS')", STR0001, 'N', 6, 0, '@E 999999'}) // #Dias Limite
	
	For nIt := 1  to Len(aFldBrw) 
          aAdd(_aFields, {aFldBrw[nIt][2], aFldBrw[nIt][3], aFldBrw[nIt][4], aFldBrw[nIt][5]})
          If !aFldBrw[nIt][2] $ "NJR_CODENT;NJR_LOJENT;NJR_TKPFIS;NJ0_NOME"         	
          	aAdd(aBrwFtr,  {aFldBrw[nIt][2], aFldBrw[nIt][1], aFldBrw[nIt][3], aFldBrw[nIt][4], aFldBrw[nIt][5], aFldBrw[nIt][6] } ) 
          EndIf
          
          Do Case 
      		Case nIt == 7
      			aAdd(aBrwFtr, {"OGC010CLS('TFISICO')", aFldBrw[nIt][1], aFldBrw[nIt][3], aFldBrw[nIt][4], aFldBrw[nIt][5], aFldBrw[nIt][6]})  // #Take-Up Fisico
      		Case nIt == 9 
      			aAdd(aBrwFtr, {"OGC010CLS('CLIENTE')", aFldBrw[nIt][1], aFldBrw[nIt][3], aFldBrw[nIt][4], aFldBrw[nIt][5], aFldBrw[nIt][6]})  // #Cliente
      		Case nIt == 12
      			aAdd(aBrwFtr, {"OGC010CLS('STAKEUP')", STR0008		  , aFldBrw[nIt][3], aFldBrw[nIt][4], aFldBrw[nIt][5], aFldBrw[nIt][6]})  // # Saldo Take-Up 
      		Case nIt == 13
      			aAdd(aBrwFtr, {"OGC010CLS('SLDRESERVA')", STR0055	  , aFldBrw[nIt][3], aFldBrw[nIt][4], aFldBrw[nIt][5], aFldBrw[nIt][6]})  // # Saldo à Reservar
      	  EndCase
    Next nIt
    
    If _oOgc010Tm != Nil // Se ja existe o objeto de tabela temporária, deleta o mesmo, fechando o alias utilizado
		_oOgc010Tm:Delete()
	EndIf
	
	_oOgc010Tm	:= FWTemporaryTable():New(_cAliasBrw) // Instancia a tabela temporária com o alias
	_oOgc010Tm:SetFields( _aFields ) // seta os campos que serão utilizados na tabela temporária
	
	/*
	  aIndices[nIt][1] - ORDEM
	  aIndices[nIt][2] - CAMPOS
	  
	  		     |-[1]-|  |--------	[2] ------------|
	  Exemplo: { {"01" , {"DXP_CODIGO", "DXP_TIPRES"} }
	*/
	
	For nIt := 1 To Len(aIndice) // Aplica os indices provenientes do parametro da OGX017
		_oOgc010Tm:AddIndex(aIndice[nIt][1], aIndice[nIt][2])
	Next nIt
	
	_oOgc010Tm:Create() // Cria a tabela temporária
    
	_cAliasBrw := OGC010TMP(cQuery) // Monta e carrega a tabela temporária

	//Definindo as colunas do Browse
	
	// Monta as colunas com as suas respectivas caracteriscas

	AAdd(aColumns,FWBrwColumn():New())
	aColumns[Len(aColumns)]:SetData( &("{||OGC010CLS('LEGENDA')}")) // Dado que ira popular o campo
	aColumns[Len(aColumns)]:SetTitle(STR0057) // ST
	aColumns[Len(aColumns)]:SetSize(1) // Tamanho
	aColumns[Len(aColumns)]:SetDecimal(0) // Decimal
	aColumns[Len(aColumns)]:SetType('BT')
	aColumns[Len(aColumns)]:SetPicture('@BMP') // Picture
	aColumns[Len(aColumns)]:SetImage(.T.) // Apresenta a imagem conforme o conteudo do campo
	aColumns[Len(aColumns)]:SetAlign( 0 )//Define alinhamento
	aColumns[Len(aColumns)]:SetDoubleClick({|| BrwLegenda(STR0014, "Legenda", _aLegenda)}) // #Prioridade de Reservas

	AAdd(aColumns,FWBrwColumn():New())
	aColumns[Len(aColumns)]:SetData( &("{||OGC010CLS('DIAS')}")) // Dado que ira popular o campo
	aColumns[Len(aColumns)]:SetTitle(STR0001) // Título da coluna#Dias Limite
	aColumns[Len(aColumns)]:SetSize(6) // Tamanho
	aColumns[Len(aColumns)]:SetDecimal(0) // Decimal
	aColumns[Len(aColumns)]:SetType('N')
	aColumns[Len(aColumns)]:SetPicture('@E 999999') // Picture
	aColumns[Len(aColumns)]:SetAlign( 1 )//Define alinhamento

	nX := 1
	AAdd(aColumns,FWBrwColumn():New())
	aColumns[Len(aColumns)]:SetData( {|| (_cAliasBrw)->NNY_CODCTR}) // Dado que ira popular o campo
	aColumns[Len(aColumns)]:SetTitle(aFldBrw[nX][1]) // Título da coluna#Contrato
	aColumns[Len(aColumns)]:SetSize(aFldBrw[nX][4]  * nAuxTam) // Tamanho
	aColumns[Len(aColumns)]:SetDecimal(aFldBrw[nX][5]) // Decimal
	aColumns[Len(aColumns)]:SetPicture(aFldBrw[nX][6]) // Picture
	aColumns[Len(aColumns)]:SetAlign( 1 )//Define alinhamento

	nX := 2
	AAdd(aColumns,FWBrwColumn():New())
	aColumns[Len(aColumns)]:SetData( {|| (_cAliasBrw)->NNY_ITEM})
	aColumns[Len(aColumns)]:SetTitle(aFldBrw[nX][1]) // #Cadência
	aColumns[Len(aColumns)]:SetSize(aFldBrw[nX][4])
	aColumns[Len(aColumns)]:SetDecimal(aFldBrw[nX][5])
	aColumns[Len(aColumns)]:SetPicture(aFldBrw[nX][6])
	aColumns[ Len(aColumns) ]:SetAlign( 1 )

	nX := 3
	AAdd(aColumns,FWBrwColumn():New())
	aColumns[Len(aColumns)]:SetData( {|| (_cAliasBrw)->DXP_CODIGO})
	aColumns[Len(aColumns)]:SetTitle(aFldBrw[nX][1]) // #Reserva
	aColumns[Len(aColumns)]:SetSize(aFldBrw[nX][4])
	aColumns[Len(aColumns)]:SetDecimal(aFldBrw[nX][5])
	aColumns[Len(aColumns)]:SetPicture(aFldBrw[nX][6])
	aColumns[ Len(aColumns) ]:SetAlign( 1 )

	nX := 4
	AAdd(aColumns,FWBrwColumn():New())
	aColumns[Len(aColumns)]:SetData({|| (_cAliasBrw)->DXP_DESRES})
	aColumns[Len(aColumns)]:SetTitle(aFldBrw[nX][1]) // #Descrição da Reserva
	aColumns[Len(aColumns)]:SetSize(aFldBrw[nX][4])
	aColumns[Len(aColumns)]:SetDecimal(aFldBrw[nX][5])
	aColumns[Len(aColumns)]:SetPicture(aFldBrw[nX][6])
	aColumns[ Len(aColumns) ]:SetAlign( 1 )

	nX := 5
	AAdd(aColumns,FWBrwColumn():New())
	aColumns[Len(aColumns)]:SetData({||(_cAliasBrw)->NNY_DATINI})
	aColumns[Len(aColumns)]:SetTitle(aFldBrw[nX][1]) // #Entrega De
	aColumns[Len(aColumns)]:SetType(aFldBrw[nX][3]) // Tipo de dado
	aColumns[Len(aColumns)]:SetSize(aFldBrw[nX][4]  * nAuxTam)
	aColumns[Len(aColumns)]:SetDecimal(aFldBrw[nX][5])
	aColumns[Len(aColumns)]:SetPicture(aFldBrw[nX][6])
	aColumns[Len(aColumns)]:SetAlign( 1 )

	nX := 6
	AAdd(aColumns,FWBrwColumn():New())
	aColumns[Len(aColumns)]:SetData({||(_cAliasBrw)->NNY_DATFIM})
	aColumns[Len(aColumns)]:SetTitle(aFldBrw[nX][1])// #Entrega Até
	aColumns[Len(aColumns)]:SetType(aFldBrw[nX][3])
	aColumns[Len(aColumns)]:SetSize(aFldBrw[nX][4] * nAuxTam)
	aColumns[Len(aColumns)]:SetDecimal(aFldBrw[nX][5])
	aColumns[Len(aColumns)]:SetPicture(aFldBrw[nX][6])
	aColumns[Len(aColumns)]:SetAlign( 1 )
	
	nX := 7
	AAdd(aColumns,FWBrwColumn():New())
	aColumns[Len(aColumns)]:SetData( &("{||OGC010CLS('TFISICO')}"))
	aColumns[Len(aColumns)]:SetTitle(aFldBrw[nX][1])// #Take-Up Físico
	aColumns[Len(aColumns)]:SetSize(aFldBrw[nX][4])
	aColumns[Len(aColumns)]:SetDecimal(aFldBrw[nX][5])
	aColumns[Len(aColumns)]:SetPicture(aFldBrw[nX][6])
	aColumns[Len(aColumns)]:SetAlign( 0 )

	nX := 8
	AAdd(aColumns,FWBrwColumn():New())
	aColumns[Len(aColumns)]:SetData( {||(_cAliasBrw)->NNY_DTLTKP})
	aColumns[Len(aColumns)]:SetTitle(aFldBrw[nX][1]) // #Data Limin Take-Up
	aColumns[Len(aColumns)]:SetType(aFldBrw[nX][3])
	aColumns[Len(aColumns)]:SetSize(aFldBrw[nX][4] * nAuxTam)
	aColumns[Len(aColumns)]:SetDecimal(aFldBrw[nX][5])
	aColumns[Len(aColumns)]:SetPicture(aFldBrw[nX][6])
	aColumns[Len(aColumns)]:SetAlign( 1 )

	nX := 9
	AAdd(aColumns,FWBrwColumn():New())
	aColumns[Len(aColumns)]:SetData( &("{||OGC010CLS('CLIENTE')}"))
	aColumns[Len(aColumns)]:SetTitle(aFldBrw[nX][1]) // #Cliente
	aColumns[Len(aColumns)]:SetSize(aFldBrw[nX][4])
	aColumns[Len(aColumns)]:SetDecimal(aFldBrw[nX][5])
	aColumns[Len(aColumns)]:SetPicture(aFldBrw[nX][6])
	aColumns[Len(aColumns)]:SetAlign( 1 )
	
	nX := 10
	AAdd(aColumns,FWBrwColumn():New())
	aColumns[Len(aColumns)]:SetData({||(_cAliasBrw)->NJR_CTREXT})
	aColumns[Len(aColumns)]:SetTitle(aFldBrw[nX][1]) // #Ctr.Externo
	aColumns[Len(aColumns)]:SetSize(aFldBrw[nX][4])
	aColumns[Len(aColumns)]:SetDecimal(aFldBrw[nX][5])
	aColumns[Len(aColumns)]:SetPicture(aFldBrw[nX][6])
	aColumns[Len(aColumns)]:SetAlign( 1 )

	nX := 11
	AAdd(aColumns,FWBrwColumn():New())
	aColumns[Len(aColumns)]:SetData({|| (_cAliasBrw)->NNY_QTDINT})
	aColumns[Len(aColumns)]:SetTitle(aFldBrw[nX][1])// #Qtd a Entregar
	aColumns[Len(aColumns)]:SetSize(aFldBrw[nX][4] * nAuxTam)
	aColumns[Len(aColumns)]:SetDecimal(aFldBrw[nX][5])
	aColumns[Len(aColumns)]:SetPicture(aFldBrw[nX][6])
	aColumns[Len(aColumns)]:SetAlign( 2 )

	// ######### Tratamento de dados. não diferenciar a posição nX
	nX := 12
	AAdd(aColumns,FWBrwColumn():New())
	aColumns[Len(aColumns)]:SetData( {|| (_cAliasBrw)->NNY_TKPQTD})
	aColumns[Len(aColumns)]:SetTitle(aFldBrw[nX][1]) //"Qtd Take-Up Efetuado"
	aColumns[Len(aColumns)]:SetSize(aFldBrw[nX][4] * nAuxTam)
	aColumns[Len(aColumns)]:SetDecimal(aFldBrw[nX][5])
	aColumns[Len(aColumns)]:SetPicture(aFldBrw[nX][6])
	aColumns[Len(aColumns)]:SetAlign( 2 )

	nX := 12
	AAdd(aColumns,FWBrwColumn():New())
	aColumns[Len(aColumns)]:SetData( &("{||OGC010CLS('STAKEUP')}"))
	aColumns[Len(aColumns)]:SetTitle(STR0008) // #"Saldo Take-UP"
	aColumns[Len(aColumns)]:SetSize(aFldBrw[nX][4] * nAuxTam)
	aColumns[Len(aColumns)]:SetDecimal(aFldBrw[nX][5])
	aColumns[Len(aColumns)]:SetPicture(aFldBrw[nX][6])
	aColumns[Len(aColumns)]:SetAlign( 2 )
	// #########################################################
	
	// ######### Tratamento de dados não diferenciar a posição nX
	nX := 13
	AAdd(aColumns,FWBrwColumn():New())
	aColumns[Len(aColumns)]:SetData( {|| (_cAliasBrw)->DXQ_PSLIQU})
	aColumns[Len(aColumns)]:SetTitle(aFldBrw[nX][1])// #Qtd. Reservada
	aColumns[Len(aColumns)]:SetSize(aFldBrw[nX][4] * nAuxTam)
	aColumns[Len(aColumns)]:SetDecimal(aFldBrw[nX][5])
	aColumns[Len(aColumns)]:SetPicture(aFldBrw[nX][6])
	aColumns[Len(aColumns)]:SetAlign( 2 )

	nX := 13
	AAdd(aColumns,FWBrwColumn():New())
	aColumns[Len(aColumns)]:SetData( &("{||OGC010CLS('SLDRESERVA')}"))
	aColumns[Len(aColumns)]:SetTitle(STR0055)// #"Saldo à Reservar"
	aColumns[Len(aColumns)]:SetSize(aFldBrw[nX][4] * nAuxTam)
	aColumns[Len(aColumns)]:SetDecimal(aFldBrw[nX][5])
	aColumns[Len(aColumns)]:SetPicture(aFldBrw[nX][6])
	aColumns[Len(aColumns)]:SetAlign( 2 )
	// #########################################################
	
	nX := 14
	AAdd(aColumns,FWBrwColumn():New())
	aColumns[Len(aColumns)]:SetData({|| (_cAliasBrw)->NJR_TIPALG})
	aColumns[Len(aColumns)]:SetTitle(aFldBrw[nX][1]) // #Tipo Algodão
	aColumns[Len(aColumns)]:SetSize(aFldBrw[nX][4] * nAuxTam)
	aColumns[Len(aColumns)]:SetDecimal(aFldBrw[nX][5])
	aColumns[Len(aColumns)]:SetPicture(aFldBrw[nX][6])
	aColumns[Len(aColumns)]:SetAlign( 1 )

	nX := 15
	AAdd(aColumns,FWBrwColumn():New())
	aColumns[Len(aColumns)]:SetData({|| (_cAliasBrw)->DXQ_BLOCO})
	aColumns[Len(aColumns)]:SetTitle(aFldBrw[nX][1])// #Blocos Vinculados
	aColumns[Len(aColumns)]:SetSize(aFldBrw[nX][4])
	aColumns[Len(aColumns)]:SetDecimal(aFldBrw[nX][5])
	aColumns[Len(aColumns)]:SetPicture(aFldBrw[nX][6])
	aColumns[Len(aColumns)]:SetAlign( 2 )

	nX := 16
	AAdd(aColumns,FWBrwColumn():New())
	aColumns[Len(aColumns)]:SetData({||(_cAliasBrw)->DXP_DATTKP})
	aColumns[Len(aColumns)]:SetTitle(AllTrim(aFldBrw[nX][1]) ) // #Data Take-Up
	aColumns[Len(aColumns)]:SetSize(aFldBrw[nX][4] * nAuxTam)
	aColumns[Len(aColumns)]:SetDecimal(aFldBrw[nX][5])
	aColumns[Len(aColumns)]:SetPicture(aFldBrw[nX][6])
	aColumns[Len(aColumns)]:SetAlign( 1 )

	_oMBrowse:SetAlias(_cAliasBrw) // Alias definido pela query
	_oMBrowse:SetMenuDef("OGC010") // Menu utilizado pelo browser
	_oMBrowse:SetDescription(STR0021)	//Necessidades de Reserva
	_oMBrowse:SetColumns(aColumns) // Colunas utilizadas pelo browser
	_oMBrowse:SetOnlyFields({'*'}) // Remove todos os campos extras exceto os definidos pelo aColumns
	_oMBrowse:DisableDetails() // Desabilita os detalhes do browser
	_oMBrowse:SetFieldFilter(aBrwFtr) // Define os campos de filtro
	
Return

/*{Protheus.doc} OGC010CLS
(Função que popula o Browser com os dados da query)
@type function
@author roney.maia
@since 20/03/2017
@version 1.0
@param cCampo, character, (Campo idendificador da coluna)
@param cCampData, character, (Data em string para conversão)
@return ${return}, ${Valor a ser populado no campo da coluna}
*/
Function OGC010CLS(cCampo, cCampData)

	Local xValor 		:= Nil
	Local aLegends		:= Iif(!Empty(MV_PAR06), Separa(MV_PAR06, ';'), {}) // Array de dias para legenda
	Local nFaixa		:= 0
	Local nIt			:= 0
	Local nX			:= 0
	Local lItBreak		:= .F.

	For nX := 1 To Len(aLegends) // Loop para remover itens vazios do array  aLegends
		If lItBreak
			Exit
		EndIf
		For nIt := 1 To Len(aLegends)
			If Empty(aLegends[nIt])
				aDel(aLegends, nIt)
				aSize(aLegends, Len(aLegends) - 1)
				Exit
			EndIf
			If nIt == Len(aLegends)
				lItBreak := .T.
			EndIf
		Next nIt
	Next nX

	If cCampo == 'CLIENTE' // Se for o campo cliente, popula com a entidade
		xValor := Posicione("NJ0", 1, FwXFilial("NJ0") + (_cAliasBrw)->NJR_CODENT + (_cAliasBrw)->NJR_LOJENT, "NJ0_NOME")
	ElseIf cCampo == 'LEGENDA' .AND. Len(aLegends) > 0 // Popula as legendas conforme o periodo em dias
		nFaixa := (_cAliasBrw)->NNY_DTLTKP - DDATABASE
		If Len(aLegends) >= 1 .AND. nFaixa >= 0 .AND. nFaixa <= Val(aLegends[1])
			xValor := "BR_LARANJA"
		ElseIf Len(aLegends) >= 2 .AND. nFaixa > Val(aLegends[1]) .AND. nFaixa <= Val(aLegends[2])
			xValor := "BR_AMARELO"
		ElseIf Len(aLegends) >= 3 .AND. nFaixa > Val(aLegends[2]) .AND. nFaixa <= Val(aLegends[3])
			xValor := "BR_VERDE"
		ElseIf	Len(aLegends) >= 4 .AND. nFaixa > Val(aLegends[3]) .AND. nFaixa <= Val(aLegends[4])
			xValor := "BR_AZUL"
		ElseIf Len(aLegends) >= 5 .AND. nFaixa > Val(aLegends[4]) .AND. nFaixa <= Val(aLegends[5])
			xValor := "BR_BRANCO"
		ElseIf nFaixa < 0
			xValor := "BR_VERMELHO"
		Else
			xValor := "BR_CINZA"
		EndIf
	ElseIf cCampo == 'LEGENDA' .AND. Len(aLegends) = 0
		nFaixa := (_cAliasBrw)->NNY_DTLTKP - DDATABASE
		If nFaixa < 0
			xValor := "BR_VERMELHO"
		Else
			xValor := "BR_AZUL_CLARO"
		EndIf
	ElseIf cCampo == 'DIAS'
		If Empty((_cAliasBrw)->NNY_DTLTKP)
			xValor := 0
		Else
			xValor := (_cAliasBrw)->NNY_DTLTKP - DDATABASE
		EndIf
	ElseIf cCampo == 'TFISICO' // Popula dependendo do tipo físico
		If AllTrim((_cAliasBrw)->NJR_TKPFIS) = '1'
			xValor := STR0084
		Else
			xValor := STR0085
		EndIf
	ElseIf cCampo == 'STAKEUP' // Popula o browser com o direncial de take-up de cada cadência
		xValor := (_cAliasBrw)->NNY_QTDINT - (_cAliasBrw)->NNY_TKPQTD
	ElseIf cCampo == 'SLDRESERVA' // Popula o browser com o direncial de Saldo Takeup e Reserva
		xValor := ((_cAliasBrw)->NNY_QTDINT - (_cAliasBrw)->NNY_TKPQTD) - (_cAliasBrw)->DXQ_PSLIQU
		if xValor < 0 //ajuste para não apresentar saldo negativo.
			xValor := 0
		endif
	EndIf

Return xValor

/*{Protheus.doc} OGC010INI
(Função acionada pela tecla F12 - para Consulta)
@type function
@author roney.maia
@since 20/03/2017
@version 1.0
*/
Static Function OGC010INI()

	Local cQuery := ""

	cQuery 	:= OGC010QRY(.T.) // Monta a query quando chamada via F12
	
	If !Empty(cQuery)
		_cAliasBrw := OGC010TMP(cQuery)
		_oMBrowse:UpdateBrowse() // Atualiza os itens do browser
		_oMBrowse:Refresh() // Aplica o Refresh no browser
	EndIf

Return

/*{Protheus.doc} OGC010QRY
(Função que monta a query para utilização da população de dados do Browse)
@type function
@author roney.maia
@since 20/03/2017
@version 1.0
@param lPergunte, ${lPergunte}, (.F. = Pergunte iniciado ao abrir a rotina, .T. = Pergunte iniciado pela tecla F12)
@return ${return}, ${Retorna a query montada a partir do pergunte}
*/
Static Function OGC010QRY(lPergunte, lPergTorF, lLineRefr)

	Local aLegends		:= {}
	Local nIt			:= 0
	Local nIt2			:= 0
	Local nX			:= 0
	Local lItBreak		:= .F.
	Local cQuery		:= ""
	Local cQueryCmp 	:= "NNY_FILIAL, NNY_CODCTR, NNY_ITEM, NNY_DATINI, NNY_DATFIM, NNY_DTLTKP, NNY_QTDINT, NNY_TKPQTD, "
	Local cQueryGrp 	:= "NNY_FILIAL, NNY_CODCTR, NNY_ITEM, NNY_DATINI, NNY_DATFIM, NNY_DTLTKP, NNY_QTDINT, NNY_TKPQTD, "
	cQueryCmp 			+= "NJR_CTREXT, NJR_CODENT, NJR_LOJENT, NJR_TKPFIS, NJR_TIPALG, COALESCE(DXP_CODIGO, '') AS DXP_CODIGO, COALESCE(DXP_DESRES, '') AS DXP_DESRES, COALESCE(DXP_DATTKP, '') AS DXP_DATTKP, COUNT(DXQ_BLOCO) AS DXQ_BLOCO, COALESCE(SUM(DXQ_PSLIQU),0) AS DXQ_PSLIQU "
	cQueryGrp			+= "NJR_CTREXT, NJR_CODENT, NJR_LOJENT, NJR_TKPFIS, NJR_TIPALG, DXP_CODIGO, DXP_DESRES, DXP_DATTKP"

	Default lPergTorF	:= .T.
	Default lLineRefr	:= .F.
	
	If lPergunte // Pergunte acionado pela tecla F12
		If ! Pergunte(_cPergunte, .T.)
			If !Empty(cQuery)
				cQuery := ChangeQuery( cQuery )
			EndIf
			Return cQuery
		EndIf
	Else // Se .T. foi chamado pelo pergunte ao abrir a rotina pela primeira vez
		If !lPergTorF // Carregamento de variaveis do pergunte
			Pergunte(_cPergunte, .F.) // Carrega o pergunte
		ElseIf ! Pergunte(_cPergunte, .T.)
			cQuery := "SELECT "+ cQueryCmp +" FROM "+ RetSqlName('NNY') + " NNYTMP"
			cQuery += ", " + RetSqlName('NJR')
			cQuery += ", " + RetSqlName('DXP')
			cQuery += ", " + RetSqlName('SB5')
			cQuery += ", " + RetSqlName('DXQ')
			cQuery += " WHERE NNYTMP.NNY_CODCTR = ''"
			cQuery += " GROUP BY " + cQueryGrp
			cQuery := ChangeQuery( cQuery )
			Return cQuery
		EndIf
	EndIf

	_aLegenda := {} // Reseta o Array de Legendas devido a novos parametros

	aLegends := Iif(!Empty(MV_PAR06), Separa(MV_PAR06, ';'), {})

	For nX := 1 To Len(aLegends)
		If lItBreak
			Exit
		EndIf
		For nIt := 1 To Len(aLegends)
			If Empty(aLegends[nIt])
				aDel(aLegends, nIt)
				aSize(aLegends, Len(aLegends) - 1)
				Exit
			EndIf
			If nIt == Len(aLegends)
				lItBreak := .T.
			EndIf
		Next nIt
	Next nX

	If Len(aLegends) > 0 // Monta a legenda que sera apresentada no clique duplo nos itens da coluna da legenda
		aAdd(_aLegenda, { "BR_VERMELHO"   , STR0010}) // #Data limite de take-up expirado
		For nIt2 := 1 To Len(aLegends)
			If nIt2 == 1
				aAdd(_aLegenda, { "BR_LARANJA"  , cValToChar(aLegends[1]) + " - " + STR0011}) // #Dias
			ElseIf nIt2 == 2
				aAdd(_aLegenda, { "BR_AMARELO"    , cValToChar(aLegends[2]) + " - " + STR0011}) // #Dias
			ElseIf nIt2 == 3
				aAdd(_aLegenda, { "BR_VERDE"   , cValToChar(aLegends[3]) + " - " + STR0011}) // #Dias
			ElseIf nIt2 == 4
				aAdd(_aLegenda, { "BR_AZUL" , cValToChar(aLegends[4]) + " - " + STR0011}) // #Dias
			ElseIf nIt2 == 5
				aAdd(_aLegenda, { "BR_BRANCO", AllTrim(cValToChar(aLegends[5])) + " - " + STR0011}) // #Dias
			EndIf
		Next nIt2
		aAdd(_aLegenda, { "BR_CINZA"   , STR0012 + " " + AllTrim(cValToChar(aLegends[Len(aLegends)])) + " " + STR0011}) // #Data limite de Take-up maior que#Dias
	Else
		aAdd(_aLegenda, { "BR_VERMELHO"   , STR0010 }) // #Data limite de take-up expirado
		aAdd(_aLegenda, { "BR_AZUL_CLARO"   ,  STR0013}) // #Prioridades do limite de Takeup
	EndIf

	cQuery := "SELECT "+ cQueryCmp +" FROM "+ RetSqlName('NNY') + " NNYTMP"

	cQuery += " INNER JOIN " + RetSqlName('NJR') + " NJRTMP ON"
	cQuery += " NJRTMP.D_E_L_E_T_ = ' '"
	cQuery += " AND NJRTMP.NJR_FILIAL = '" + FwXFilial('NJR') + "'"
	cQuery += " AND NJRTMP.NJR_CODCTR = NNYTMP.NNY_CODCTR"
	cQuery += " AND (NJRTMP.NJR_STATUS = 'A' OR NJRTMP.NJR_STATUS = 'I')"
	cQuery += " AND NJRTMP.NJR_TIPALG <> ''"

	cQuery += " LEFT OUTER JOIN " + RetSqlName('DXP') + " DXPTMP ON"
	cQuery += " DXPTMP.D_E_L_E_T_ = ' '"
	cQuery += " AND DXPTMP.DXP_FILIAL = '" + FwXFilial('DXP') + "'"
	cQuery += " AND DXPTMP.DXP_CODCTP = NJRTMP.NJR_CODCTR"
	cQuery += " AND DXPTMP.DXP_ITECAD = NNYTMP.NNY_ITEM"
	cQuery += " AND DXPTMP.DXP_STATUS <> '2'"

	cQuery += " INNER JOIN " + RetSqlName('SB5') + " SB5TMP ON"
	cQuery += " SB5TMP.D_E_L_E_T_ = ' '"
	cQuery += " AND SB5TMP.B5_FILIAL = '" + FwXFilial('SB5') + "'"
	cQuery += " AND SB5TMP.B5_COD = NJRTMP.NJR_CODPRO"
	cQuery += " AND SB5TMP.B5_TPCOMMO = '2'"

	cQuery += " LEFT OUTER JOIN " + RetSqlName('DXQ') + " DXQTMP ON"
	cQuery += " DXQTMP.D_E_L_E_T_ = ' '"
	cQuery += " AND DXQTMP.DXQ_FILIAL = '" + FwXFilial('DXQ') + "'"
	cQuery += " AND DXQTMP.DXQ_CODRES = DXPTMP.DXP_CODIGO"

	cQuery += " WHERE NNYTMP.D_E_L_E_T_ = ' '"
	cQuery += " AND NNYTMP.NNY_FILIAL = '" + FwXFilial('NNY') + "'"

	If (!Empty(MV_PAR01)) .AND. (!Empty(MV_PAR02))  // Entrega De ? Entrega Até ?
		cQuery += " AND (((NNY_DATINI BETWEEN '" + dToS(MV_PAR01) + "' AND '"  + dToS(MV_PAR02) + "') OR "
		cQuery += "      (NNY_DATFIM BETWEEN '" + dToS(MV_PAR01) + "' AND '"  + dToS(MV_PAR02) + "')) "
		cQuery += "   OR (('"+dToS(MV_PAR01)+ "' BETWEEN NNY_DATINI AND NNY_DATFIM ) OR "
		cQuery += "       ('"+dToS(MV_PAR02)+ "' BETWEEN NNY_DATINI AND NNY_DATFIM ))) "
	EndIf

	If (!Empty(MV_PAR01)) .AND. (Empty(MV_PAR02))  // Entrega De ? Entrega Até ?
		cQuery += " AND (NNY_DATINI >= '" + dToS(MV_PAR01) + "')"
	EndIf

	If (Empty(MV_PAR01)) .AND. (!Empty(MV_PAR02))  // Entrega De ? Entrega Até ?
		cQuery += " AND (NNY_DATFIM <= '" + dToS(MV_PAR02) + "')"
	EndIf

	If !Empty(MV_PAR03) // T.Físico
		If MV_PAR03 != 3
			cQuery += " AND NJR_TKPFIS = '" + cValToChar(MV_PAR03) + "'"
		EndIf
	EndIf

	If !Empty(MV_PAR04)
		cQuery += " AND NNY_DTLTKP <= '" + dToS(MV_PAR04) + "'"
	EndIf

	If !Empty(MV_PAR05)
		cQuery += " AND NJR_TIPO = '" + cValToChar(MV_PAR05) + "'"
	EndIf
	
	cQuery += " AND (NNY_QTDINT - (NNY_QTDINT * NJR_TOLENT / 100 )) > NNY_TKPQTD"	 // Take up igual ou maior que o percentual minimo não é listado
	
	If lLineRefr // Se for refresh de linha do browse
		cQuery += " AND (NNY_CODCTR = '" + (_cAliasBrw)->NNY_CODCTR + "' AND NNY_ITEM = '" + (_cAliasBrw)->NNY_ITEM + "')"	 // Take up igual ou maior que o percentual minimo não é listado
	EndIf 

	cQuery += " GROUP BY " + cQueryGrp
	cQuery += " ORDER BY NNY_DTLTKP "
	
	cQuery := ChangeQuery( cQuery )

Return cQuery

/*{Protheus.doc} OGC010LVL
(Função de validação do campo Prioridade de Remessa na Pergunta - SX1)
@type function
@author roney.maia
@since 23/03/2017
@version 1.0
@param cValor, character, (Descrição do parâmetro)
@return ${return}, ${return_description}
@example
(examples)
@see (links_or_references)
*/
Function OGC010LVL(cValor)

	Local lRet 			:= .T.
	Local aLegends 		:= Iif(!Empty(cValor), Separa(MV_PAR06, ';'), {})
	Local nTamLeg		:= 0
	Local nIt 			:= 0
	Local nIt2 			:= 0
	Local nIt3			:= 0
	Local nX			:= 0
	Local lItBreak		:= .F.

	For nX := 1 To Len(aLegends) // Redimensiona o tamanho do array se caso posições em branco
		If lItBreak
			Exit
		EndIf
		For nIt3 := 1 To Len(aLegends)
			If Empty(aLegends[nIt3])
				aDel(aLegends, nIt3)
				aSize(aLegends, Len(aLegends) - 1)
				Exit
			EndIf
			If nIt3 == Len(aLegends)
				lItBreak := .T.
			EndIf
		Next nIt3
	Next nX

	nTamLeg := Len(aLegends)

	If nTamLeg > 0
		If nTamLeg >= 1
			If nTamLeg > 5
				Help('', 1, "OGC0100001") // #Máximo de dias informados não podem ser maior que 5.
				Return .F.
			EndIf
			For nIt := 1 To nTamLeg
				For nIt2 := 1 To Len(aLegends[nIt])
					If SubStr(aLegends[nIt], nIt2, 1) == '-'
						Help('', 1, "OGC0100002") // #Favor informar valores positivos
						Return .F.
					EndIf
				Next nIt2
			Next nIt
			For nIt := 1 To nTamLeg - 1
				If Val(aLegends[nIt]) > Val(aLegends[nIt + 1])
					Help('', 1, "OGC0100003") // #Os dias devem ser informados em valores crescentes
					Return .F.
				EndIf
				If Val(aLegends[nIt]) = Val(aLegends[nIt + 1])
					Help('', 1, "OGC0100004") // #Os dias informados não podem ser iguais
					Return .F.
				EndIf
			Next nIt
		EndIf
	EndIf

Return lRet

/*{Protheus.doc} OGC10RES
Função que realiza a reserva atraves da rotina AGRA720.

@author 	ana.olegini
@since 		29/03/2017
@version 	1.0
@return 	lContinua, logico, para verdadeiro .t. para falso .f.
/*/
Function OGC10RES()

	Local aArea		:= GetArea()
	Local lContinua := .T.
	Local nRetorno	:= 0
	Local cPrograma := STR0050		//Agra720 - Reservas
	Local cTitulo	:= ''
	Local cReserva	:= (_cAliasBrw)->DXP_CODIGO

	Local aItens	:= {}
	Local aItensBkp := {}
	Local nOper     := Nil

	//*Envia para rotina AGRA720
	Private _cSafraCad 	:= Alltrim(Posicione("NJR",1,FwXFilial("NJR")+(_cAliasBrw)->NNY_CODCTR, "NJR_CODSAF"))
	Private _cCodOgCli	:= Posicione("NJ0", 1, FwXFilial("NJ0") + (_cAliasBrw)->NJR_CODENT + (_cAliasBrw)->NJR_LOJENT, "NJ0_CODCLI")
	Private _cCodOgLoj	:= Posicione("NJ0", 1, FwXFilial("NJ0") + (_cAliasBrw)->NJR_CODENT + (_cAliasBrw)->NJR_LOJENT, "NJ0_LOJCLI")
	Private _cCntrCade 	:= (_cAliasBrw)->NNY_CODCTR
	Private _cItemCade 	:= (_cAliasBrw)->NNY_ITEM
	Private _cCodClass 	:= Posicione("NJR",1,FwXFilial("NJR")+(_cAliasBrw)->NNY_CODCTR, "NJR_TIPALG")

	if !empty(_cCntrCade)
		dbSelectArea("DXP")
		dbSetOrder(1)
		If dbSeek(FwXFilial("DXP")+cReserva)
			//*Para alteração
			cTitulo  := STR0048
			nOper    := MODEL_OPERATION_UPDATE
			aItensBkp := OGX014QRY(Nil, cReserva ) // Executa a query para buscar as reservas com agendamentos
			nRetorno := FWExecView (cTitulo, cPrograma, MODEL_OPERATION_UPDATE,/*oDlg*/ , {||.T.},/*bOk*/ ,12/*nPercReducao*/ ,/*aEnableButtons*/ , /*bCancel*/ )
			aItens	  := OGX014QRY(Nil, cReserva ) // Executa a query para buscar as reservas com agendamentos
	    Else
	    	//*Para inclusão
	    	cTitulo  := STR0049
	    	nOper    := MODEL_OPERATION_INSERT
	 		nRetorno := FWExecView (cTitulo, cPrograma, MODEL_OPERATION_INSERT,/*oDlg*/ , {||.T.},/*bOk*/ ,12/*nPercReducao*/ ,/*aEnableButtons*/ , /*bCancel*/ )
	    Endif

		If nRetorno == 0
			lContinua := .T.
		ElseIf nRetorno == 1
			lContinua := .F.
		EndIf
		OGC010LREF() // Atualiza o browser
	endif
	
	RestArea(aArea)

Return(lContinua)

/*{Protheus.doc} OGC010EXV
(Função que realizará a chamada a Rotina de Agendamento do Take-Up (OGX014))
@type function
@author roney.maia
@since 26/05/2017
@version 1.0
*/
Function OGC010EXV()

	Local aArea			:= GetArea()
	Local nRet			:= 1
	Local lRet			:= .T.
	Local aButtons 		:= {{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.T.,STR0058},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil}} // # Fechar
	PRIVATE _lAgdAtrs  	:= .F.
	Private _oCalend 	:= Nil // Objeto referente ao calendario
	Private _aItens		:= {} // Array de itens agendados que serão apresentados na widget de calendário
	Private _aItensBkp  := {}
	Private _cCodRes	:= "" // Código da reserva que será atribuida para o caso de ouver desposicionamento do browse
	Private _lIns		:= .F. // Varável de controle para indicar se é modo de inserção
	Private _nOperation	:= MODEL_OPERATION_VIEW
	Private _aPoolDt	:= {} // Array de botões de dias da agenda

	_lOgc010Ag  	:= .T. // .F. quando existe agendamento na  e .T. Quando não existe agendamento na reserva.
	_lOgc010Re  	:= .T. // .F. quando existe agendamento na  e .T. Quando não existe agendamento na reserva.
	_lAgdAtrs		:= .F. // Quanto .T. deverá abrir a tela para motivo de agendamento atrasado no AGRA720

	If ((_cAliasBrw)->NNY_DTLTKP - DDATABASE) < 0 // Se a data limite do take-up for menor que a data atual
	   //Chama a tela de Justificativa para informar o motivo do atraso no agendamento
		dBSelectArea("DXP") // Seleciona a tabela da DXP
		DXP->(dbSetOrder(1)) // Seta o indice utilizado
		DXP->(dbSeek(FwXFilial("DXP") + (_cAliasBrw)->DXP_CODIGO)) // procura e posiciona no registro que será atualizado

	   If .NOT. Empty((_cAliasBrw)->DXP_CODIGO) .AND. Empty(DXP->DXP_DATAGD) // se o codigo da reserva da cadencia não existe e está atrasado, então Deve informar o motivo do TU atrasado
   	        If 0 == AGRGRAVAHIS(STR0068, "DXP",FwxFilial('DXP')+(_cAliasBrw)->DXP_CODIGO,"O" )  //#Motivo Inclusão Take-up atrasado
   	           Return
   	        EndIf
   	   ElseIF Empty(DXP->DXP_DATAGD)
   	   		_lAgdAtrs	:= .T.
   	   EndIf
   	EndIf

	If Empty((_cAliasBrw)->DXP_CODIGO) // se o codigo da reserva da cadencia não existe, então sera realizado uma nova reserva
		_cCodRes := (_cAliasBrw)->DXP_CODIGO
		nRet := FWExecView(STR0025, 'OGX014', MODEL_OPERATION_INSERT, , {|| .T.}, , 5 / 100, aButtons) // # "Agendamento de Take-Up
		_lOgc010Re := .F.
	Else
		dBSelectArea("DXP") // Seleciona a tabela da DXP
		DXP->(dbSetOrder(1)) // Seta o indice utilizado
		DXP->(dbSeek(FwXFilial("DXP") + (_cAliasBrw)->DXP_CODIGO)) // procura e posiciona no registro que será atualizado

		If !Empty(DXP->DXP_DATAGD) .AND. !Empty(DXP->DXP_HORAGD) // Verifica se a reserva ja possui um agendamento
	 		MsgInfo( STR0031 + " " + Day2Str(DXP->DXP_DATAGD) + ;  // # "A Reserva já possui agendamento para a data"
	 				"/" + Month2Str(DXP->DXP_DATAGD) + "/" + Year2Str(DXP->DXP_DATAGD) + " " + STR0032 + " " + AllTrim(DXP->DXP_HORAGD) + " " + STR0033) // #às#horas.
	 		_lOgc010Ag := .F.  //seta valor verdadeiro identificar que ja existe agenda. Usado no registro de histórico do agra720
		EndIf

		_cCodRes := (_cAliasBrw)->DXP_CODIGO
		nRet := FWExecView(STR0025, 'OGX014', MODEL_OPERATION_UPDATE, , {|| .T.}, , 5 / 100, aButtons) // # "Agendamento de Take-Up

		DXP->(dBCloseArea())
	EndIf

	If nRet == 0
		lRet := .T.
	ElseIf nRet == 1
		lRet := .F.
	EndIf

	OGC010LREF() // Atualiza linha posicionada do browse
	
	RestArea(aArea)

Return lRet

/*{Protheus.doc} OGC010LOG
   c
(Função executa AGRHISTTAB para exibir o log de motivos ou de alteração
@type function
@author Marcelo Ferrari
@since 14/06/2017
@version 1.0
@param cTipo, character
@return ${Nil}, ${return_description}
*/
Function OGC010LOG() //cTabela,cChave,nSubStr)

	Local cChave := FwxFilial('DXP') + (_cAliasBrw)->DXP_CODIGO
    AGRHISTTABE("DXP",cChave,NIL)
    OGC010LREF() // Atualiza linha posicionada do browse
Return

/*{Protheus.doc} OGC010TMP
//Função que monta e popula a tabela temporária.
@author roney.maia
@since 21/02/2018
@version 1.0
@return ${return}, ${Alias da Tabela Temporaria}
@param cQuery, characters, Query que fará a carga de dados para a tabela temporaria
@type function
*/
Static Function OGC010TMP(cQuery)

	Local cAliasQry := GetNextAlias() // Obtem o proximo alias disponivel, tabela query
	Local nIt		:= 0
	Local cQryTmp 	:= ChangeQuery( cQuery )
	Local aStruct	:= {}
	
	If Select(_cAliasBrw) > 0 // Caso a tabela existir e estiver populada, refaz a mesma
		(_cAliasBrw)->(dBGoTop())
		If !(_cAliasBrw)->(Eof())
			While !(_cAliasBrw)->(Eof())
				If RecLock((_cAliasBrw),.F.)
					(_cAliasBrw)->(DbDelete())
					(_cAliasBrw)->(MsUnlock())
				EndIf
				(_cAliasBrw)->( dbSkip())
			EndDo
		EndIf
	EndIf
	
	// ############### Populando a tabela temporária que será utilizada no browse ##################
	If Select(cAliasQry) > 0 // Se o alias estiver aberto, fecha o alias
		(cAliasQry)->( dbCloseArea() )
	EndIf
	
	dbUseArea( .T., "TOPCONN", TcGenQry( , , cQryTmp ), cAliasQry, .F., .T. ) // Executa a query
	aStruct := (cAliasQry)->(dBStruct()) // Obtém a estrutura da tabela query
	
	Do While !(cAliasQry)->(Eof()) // Popula a tabela temporária
		RecLock((_cAliasBrw),.T.)
			For nIt := 1 To Len(_aFields)
				If aScan(aStruct, {|x| AllTrim(x[1]) == AllTrim(_aFields[nIt][1]) }) > 0 // Verifica se o campo existe, para popular a tabela temporária
					(_cAliasBrw)->&(_aFields[nIt][1])	:= OGC010TRT((cAliasQry)->&(_aFields[nIt][1]), _aFields[nIt][2])
				EndIf		
			Next nIt
		MsUnlock()
		(cAliasQry)->(dbSkip())
	EndDo
	
	(_cAliasBrw)->(dbGoTop()) // Posiciona no topo
	(cAliasQry)->(dbCloseArea())
	
Return _cAliasBrw

/*{Protheus.doc} OGC010TRT
//Converte valores de campos especificos para caracter.
@author roney.maia
@since 28/08/2017
@version 6
@param xValor, , Valor do campo
@param cType, , Tipo do campo
@type function
*/
Static Function OGC010TRT(xValor, cType)

	Local cValCmp 	:= ""
	
	Default xValor 	:= Nil
	Default cType   := ""
	
	If .NOT. Empty(cType) // Trata valores do alias query
	
		Do Case
	        Case cType == "N"
	            cValCmp := xValor
	        Case cType == "M"
	            cValCmp := xValor
	        Case cType == "D"
	            cValCmp := STOD(xValor)
	        Case cType == "L"
	            If AllTrim(xValor) == "T"
	                cValCmp := .T.// # verdadeiro
	            Else
	                cValCmp := .F. // # falso
	            EndIf
	        Case cType == "C"
	            cValCmp := xValor
	    EndCase
	    
	ElseIf xValor != Nil // Trata valores do parse html
	
	    Do Case
	        Case ValType(xValor) == "N"
	            cValCmp := cValToChar(xValor)
	        Case ValType(xValor) == "M"
	            cValCmp := xValor
	        Case ValType(xValor) == "D"
	            cValCmp := DTOC(xValor)
	        Case ValType(xValor) == "C"
	            If AllTrim(xValor) == "T"
	                cValCmp := STR0086 // # verdadeiro
	            ElseIf AllTrim(xValor) == "F"
	                cValCmp := STR0087 // # falso
	            Else
	            	cValCmp := xValor
	            EndIf   
	    EndCase
	    
	EndIf

Return Iif(ValType(cValCmp) == "C" , AllTrim(cValCmp), cValCmp)

/*{Protheus.doc} OGC010LREF
//TODO Descrição auto-gerada.
@author roney.maia
@since 22/02/2018
@version 1.0
@return ${return}, ${return_description}
@type function
*/
Static Function OGC010LREF()

	Local aArea		:= GetArea()
	Local cQuery 	:= OGC010QRY(.F., .F., .T.) // Query usando os parametros do pergunte salvos e com refresh de linha
	Local cAliasQry := GetNextAlias()
	Local aStruct	:= {}
	Local nIt		:= 0
	
	// ############### Populando a tabela temporária que será utilizada no browse ##################
	If Select(cAliasQry) > 0 // Se o alias estiver aberto, fecha o alias
		(cAliasQry)->( dbCloseArea() )
	EndIf
	
	dbUseArea( .T., "TOPCONN", TcGenQry( , , cQuery ), cAliasQry, .F., .T. ) // Executa a query
	aStruct := (cAliasQry)->(dBStruct()) // Obtém a estrutura da tabela query
	
	dbSelectArea(cAliasQry)
	(cAliasQry)->(dbGoTop())
	
	If !(cAliasQry)->(Eof()) // Atualiza linha do browse
		RecLock((_cAliasBrw),.F.)
			For nIt := 1 To Len(_aFields)
				If aScan(aStruct, {|x| AllTrim(x[1]) == AllTrim(_aFields[nIt][1]) }) > 0 // Verifica se o campo existe, para popular a tabela temporária
					(_cAliasBrw)->&(_aFields[nIt][1]) := OGC010TRT((cAliasQry)->&(_aFields[nIt][1]), _aFields[nIt][2])
				EndIf		
			Next nIt
		MsUnlock()
	EndIf
	
	(cAliasQry)->(dbCloseArea())
	RestArea(aArea)
	_oMBrowse:LineRefresh()
	
Return
