#INCLUDE "OGC180.CH" 
#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"

Static __oArqTemp  := Nil	//Objeto retorno da tabela

/*/{Protheus.doc} OGC180
//Analise de Exposição de Contratos Futuros
@author carlos.augusto/marcelo.ferrari
@since 09/11/2018
@version 1.0
@return ${return}, ${return_description}

@type function
/*/
function OGC180(cProduto)
	Local aFilBrowCtr   := {}
    Local cFiltroDef 	:= ""
	Local nCont         := 0
	Private _cFiltro    := nil
	Private _cTabCtr    := nil
	Private _oBrowse    := nil
	Private _aFieldsQry := nil
    Private _aCpsBrowCt := nil
	Private _cBasis     := ""
    Private _aIdxBrw    := {}

	//-- Proteção de Código
	If .Not. TableInDic('NCS') .OR. .Not. TableInDic('NCS')  .OR. .Not. TableInDic('NCS')
		MsgNextRel() //-- É necessário a atualização do sistema para a expedição mais recente
		Return()
	Endif

    If !OGC180VLDROTINA()    
        Return()
    EndIf
    
	//atalho de pesquisa
	SetKey( VK_F12, { || OGC180F12() } )
	//Pergunta para selecionar o componente BASIS.
	_cBasis := OGC180PERG(.F.)
	If Empty(_cBasis)
	   OGC180PERG(.t.)
	EndIf

	//CAMPOS DA TABELA TEMPORÁRIA
    _aFieldsQry := { ;        
		/*"Índice"           */ {STR0016                 , "INDICE"        ,TamSX3("NK0_INDICE")[3] ,TamSX3("NK0_INDICE")[1]  ,TamSX3("NK0_INDICE")[2]  ,PesqPict("NK0","NK0_INDICE")}  ,;   //
        /*NK0_DATVEN         */ {AgrTitulo("NK0_DATVEN") , "DATVENCTO"     ,TamSX3("NK0_DATVEN")[3] ,TamSX3("NK0_DATVEN")[1]  ,TamSX3("NK0_DATVEN")[2]  ,PesqPict("NK0","NK0_DATVEN")}  ,;   //
		/*NCS_BOLSA          */ {AgrTitulo("NCS_BOLSA")  , "BOLSA"         ,TamSX3("NCS_BOLSA")[3]  ,TamSX3("NCS_BOLSA")[1]   ,TamSX3("NCS_BOLSA")[2]   ,PesqPict("NCS","NCS_BOLSA")}   ,;      //
        /*NK0_VMESAN         */ {AgrTitulo("NK0_VMESAN") , "VCTMESAN"      ,TamSX3("NK0_VMESAN")[3] ,TamSX3("NK0_VMESAN")[1]  ,TamSX3("NK0_VMESAN")[2]  ,PesqPict("NK0","NK0_VMESAN")}  ,;      //
 		/*NCS_SAFRA          */ {AgrTitulo("NCS_SAFRA")  , "SAFRA"         ,TamSX3("NCS_SAFRA")[3]  ,TamSX3("NCS_SAFRA")[1]   ,TamSX3("NCS_SAFRA")[2]   ,PesqPict("NCS","NCS_SAFRA")}   ,;      //
		/*"Qtd.Ctr.Futuro"   */ {STR0004                 , "QTDCTRFUT"     ,TamSX3("NCS_QTDE")[3]   ,TamSX3("NCS_QTDE")[1]    ,TamSX3("NCS_QTDE")[2]    ,PesqPict("NCS","NCS_QTDE")}    ,;     //Qtd Ctr Futuro" 
	 	/*"Vlr.Med.Prod/Ctr" */ {STR0005	             , "VLRMEDCTFT"    ,TamSX3("N7C_VLRCOM")[3] ,TamSX3("N7C_VLRCOM")[1]  ,TamSX3("N7C_VLRCOM")[2]  ,PesqPict("N7C","N7C_VLRCOM")}  ,;     //Vlr Md. Prod/Ctr" 
		/*"Qtd.Vol.Ctr.Fut"  */ {STR0006	             , "TTQTDCTR"      ,TamSX3("N7C_QTAFIX")[3] ,TamSX3("N7C_QTAFIX")[1]  ,TamSX3("N7C_QTAFIX")[2]  ,PesqPict("N7C","N7C_QTAFIX")}  ,;     //Qtde TT. Contrato
		/*"Vlr.Tt.Ctr.Fut"   */ {STR0007	             , "VLRTOTCTFT"    ,TamSX3("NCS_VALOR")[3]  ,TamSX3("NCS_VALOR")[1]   ,TamSX3("NCS_VALOR")[2]   ,PesqPict("NCS","NCS_VALOR")}  ,;     //Total Contrato" 
		/*NK8_CODPRO         */ {AgrTitulo("NK8_CODPRO") , "CODPRODUTO"    ,TamSX3("NK8_CODPRO")[3] ,TamSX3("NK8_CODPRO")[1]  ,TamSX3("NK8_CODPRO")[2]  ,PesqPict("NK8","NK8_CODPRO")}  ,;      //
		/*B1_DESC            */ {AgrTitulo("B1_DESC")    , "DESCPRODUT"    ,TamSX3("B1_DESC")[3]    ,TamSX3("B1_DESC")[1]     ,TamSX3("B1_DESC")[2]     ,PesqPict("SB1","B1_DESC")}     ,;      //
		/*N7C_UMPROD         */ {AgrTitulo("N7C_UMPROD") , "UNMEDPROD"     ,TamSX3("N7C_UMPROD")[3] ,TamSX3("N7C_UMPROD")[1]  ,TamSX3("N7C_UMPROD")[2]  ,PesqPict("N7C","N7C_UMPROD")}  ,;      //
		/*N8U_QTDCTR         */ {AgrTitulo("N8U_QTDCTR") , "QTDXCTRFUT"    ,TamSX3("N8U_QTDCTR")[3] ,TamSX3("N8U_QTDCTR")[1]  ,TamSX3("N8U_QTDCTR")[2]  ,PesqPict("N8U","N8U_QTDCTR")}  ,;      //
		/*"Un.Med.Ctr.Fut"   */ {STR0008                 , "UNMEDCTRFT"    ,TamSX3("N8U_UMCTR")[3]  ,TamSX3("N8U_UMCTR")[1]   ,TamSX3("N8U_UMCTR")[2]   ,PesqPict("N8U","N8U_UMCTR")}   ,;       //
		/*N7C_CODCOM         */ {AgrTitulo("N7C_CODCOM") , "COMPONENTE"    ,TamSX3("N7C_CODCOM")[3] ,TamSX3("N7C_CODCOM")[1]  ,TamSX3("N7C_CODCOM")[2]  ,PesqPict("N7C","N7C_CODCOM")}  ,; //
        /*NK7_DESCRI         */ {AgrTitulo("NK7_DESCRI") , "NOMECOMP"      ,TamSX3("NK7_DESCRI")[3] ,TamSX3("NK7_DESCRI")[1]  ,TamSX3("NK7_DESCRI")[2]  ,PesqPict("NK7","NK7_DESCRI")}  ,; //
		/*N7C_UMCOM          */ {AgrTitulo("N7C_UMCOM")  , "UNMEDCOMP "    ,TamSX3("N7C_UMCOM")[3]  ,TamSX3("N7C_UMCOM")[1]   ,TamSX3("N7C_UMCOM")[2]   ,PesqPict("N7C","N7C_UMCOM")}   ,;       //
 		/*"Cod. Moeda"       */ {STR0009                 , "CODMOEDA"      ,TamSX3("NK0_MOEDA")[3]  ,TamSX3("NK0_MOEDA")[1]  ,TamSX3("NK0_MOEDA")[2]    ,PesqPict("NK0","NK0_MOEDA")}   ,; //
		/*"Moeda"            */ {STR0010                 , "MOEDA"         ,"C"                     ,10                       ,0                        , "@!" }                        ,; //
		/*N7C_QTDCTR         */ {AgrTitulo("N7C_QTDCTR") , "QTCTNEGOCI"    ,TamSX3("N7C_QTDCTR")[3] ,TamSX3("N7C_QTDCTR")[1]  ,TamSX3("N7C_QTDCTR")[2]  ,PesqPict("N7C","N7C_QTDCTR")}  ,; //
		/*N7C_QTAFIX         */ {AgrTitulo("N7C_QTAFIX") , "QTDNEGOCIO"    ,TamSX3("N7C_QTAFIX")[3] ,TamSX3("N7C_QTAFIX")[1]  ,TamSX3("N7C_QTAFIX")[2]  ,PesqPict("N7C","N7C_QTAFIX")}  ,; //
		/*TTVLRFIX           */ {AgrTitulo("TTVLRFIX")   , "TTVLRFIX"      ,TamSX3("N7C_VLRCOM")[3] ,TamSX3("N7C_VLRCOM")[1]  ,TamSX3("N7C_VLRCOM")[2]  ,PesqPict("N7C","N7C_VLRCOM")}  ,;
        /*"BASIS"            */ {STR0011                 , "COMPBASIS"     ,TamSX3("N7C_CODCOM")[3] ,TamSX3("N7C_CODCOM")[1]  ,TamSX3("N7C_CODCOM")[2]  ,PesqPict("N7C","N7C_CODCOM")}  ,;
		/*"Un.Med.Basis"     */ {STR0013                 , "UNMEDBASIS"    ,TamSX3("N7C_UMCOM")[3]  ,TamSX3("N7C_UMCOM")[1]   ,TamSX3("N7C_UMCOM")[2]   ,PesqPict("N7C","N7C_UMCOM")}   ,;       //
		/*"Vlr.Med.Basis"    */ {STR0012                 , "VLRMEDBASI"    ,TamSX3("N7C_VLRCOM")[3] ,TamSX3("N7C_VLRCOM")[1]  ,TamSX3("N7C_VLRCOM")[2]  ,PesqPict("N7C","N7C_VLRCOM")}  ,;       //
		/*"Qtd.Ctr.a.Fixar"  */ {STR0020                 , "QTDCTRAFIX"    ,TamSX3("NCS_QTDE")[3]   ,TamSX3("NCS_QTDE")[1]    ,TamSX3("NCS_QTDE")[2]    ,PesqPict("NCS","NCS_QTDE")}    ,;       //
		/*"Qtd.Vol.a.Fixar"  */ {STR0022                 , "QTDCOMPFIX"    ,TamSX3("N7C_QTAFIX")[3] ,TamSX3("N7C_QTAFIX")[1]  ,TamSX3("N7C_QTAFIX")[2]  ,PesqPict("N7C","N7C_QTAFIX")}  ,;       //
		/*"Sld.Ctr.L.Hedge"  */{STR0021                  , "QTDCTRSHED"    ,TamSX3("N7C_QTAFIX")[3] ,TamSX3("N7C_QTAFIX")[1]  ,TamSX3("N7C_QTAFIX")[2]  ,PesqPict("N7C","N7C_QTAFIX")}  ,;       //
        /*"Sld.Vol.L.Hedge"  */{STR0023                  , "QTDCOMSHED"    ,TamSX3("N7C_QTAFIX")[3] ,TamSX3("N7C_QTAFIX")[1]  ,TamSX3("N7C_QTAFIX")[2]  ,PesqPict("N7C","N7C_QTAFIX")}  ,;       //
        /*"Vlr.Med.Ctr.S/.Basis" */ {STR0024             , "VLCTFUTBAS"    ,TamSX3("N7C_VLRCOM")[3] ,18                       ,TamSX3("N7C_VLRCOM")[2]  ,PesqPict("N7C","N7C_VLRCOM")}   ;       //
        }     //
	
	//CAMPOS DO GRID
    _aCpsBrowCt := { ;        
 		/*"Safra"            */ {AgrTitulo("NCS_SAFRA")  , "SAFRA"         ,TamSX3("NCS_SAFRA")[3]  ,TamSX3("NCS_SAFRA")[1]   ,TamSX3("NCS_SAFRA")[2]   ,PesqPict("NCS","NCS_SAFRA")}  ,;      //
		/*"Índice"           */ {STR0016                 , "INDICE"        ,TamSX3("NK0_INDICE")[3] ,TamSX3("NK0_INDICE")[1]  ,TamSX3("NK0_INDICE")[2]  ,PesqPict("NK0","NK0_INDICE")} ,;   //
		/*"Qtd.Ctr.Futuro"   */ {STR0004                 , "QTDCTRFUT"     ,TamSX3("NCS_QTDE")[3]   ,TamSX3("NCS_QTDE")[1]    ,TamSX3("NCS_QTDE")[2]    ,PesqPict("NCS","NCS_QTDE")}   ,;     //Qtd Ctr Futuro" 
        /*"Qtd.Ctr.a.Fixar"  */ {STR0020                 , "QTDCTRAFIX"    ,TamSX3("NCS_QTDE")[3]   ,TamSX3("NCS_QTDE")[1]    ,TamSX3("NCS_QTDE")[2]    ,PesqPict("NCS","NCS_QTDE")}   ,;       //
		/*"Sld.Ctr.L.Hedge"  */ {STR0021                 , "QTDCTRSHED"    ,TamSX3("NCS_QTDE")[3]   ,TamSX3("NCS_QTDE")[1]    ,TamSX3("NCS_QTDE")[2]    ,PesqPict("NCS","NCS_QTDE")}   ,;       //
		/*"Qtd.Vol.Ctr.Fut"  */ {STR0006	             , "TTQTDCTR"      ,TamSX3("N7C_QTAFIX")[3] ,TamSX3("N7C_QTAFIX")[1]  ,TamSX3("N7C_QTAFIX")[2]  ,PesqPict("N7C","N7C_QTAFIX")} ,;     //Qtde TT. Contrato
		/*"Qtd.Vol.a.Fixar"  */ {STR0022                 , "QTDCOMPFIX"    ,TamSX3("N7C_QTAFIX")[3] ,TamSX3("N7C_QTAFIX")[1]  ,TamSX3("N7C_QTAFIX")[2]  ,PesqPict("N7C","N7C_QTAFIX")} ,;       //
        /*"Sld.Vol.L.Hedge"  */ {STR0023                 , "QTDCOMSHED"    ,TamSX3("N7C_QTAFIX")[3] ,TamSX3("N7C_QTAFIX")[1]  ,TamSX3("N7C_QTAFIX")[2]  ,PesqPict("N7C","N7C_QTAFIX")} ,;       //
		/*"Un.Med.Ctr.Fut"   */ {STR0008                 , "UNMEDCTRFT"    ,TamSX3("N8U_UMCTR")[3]  ,TamSX3("N8U_UMCTR")[1]   ,TamSX3("N8U_UMCTR")[2]   ,PesqPict("N8U","N8U_UMCTR")}  ,;       //
	 	/*"Vlr.Med.Prod/Ctr" */ {STR0005	             , "VLRMEDCTFT"    ,TamSX3("NCS_VALOR")[3]  ,TamSX3("NCS_VALOR")[1]   ,TamSX3("NCS_VALOR")[2]   ,PesqPict("NCS","NCS_VALOR")} ,;     //Vlr Md. Prod/Ctr" 
		/*"Vlr.Med.Ctr.S/.Basis*/{STR0024                , "VLCTFUTBAS"    ,TamSX3("NCS_VALOR")[3]  ,TamSX3("NCS_VALOR")[1]   ,TamSX3("NCS_VALOR")[2]   ,PesqPict("NCS","NCS_VALOR")} ,;       //
		/*"Un.Med.Comp."     */ {STR0025                 , "UNMEDCOMP "    ,TamSX3("N7C_UMCOM")[3]  ,TamSX3("N7C_UMCOM")[1]   ,TamSX3("N7C_UMCOM")[2]   ,PesqPict("N7C","N7C_UMCOM")}  ,;       //
        /*"Vlr.Tt.Ctr.Fut"   */ {STR0007	             , "VLRTOTCTFT"    ,TamSX3("NCS_VALOR")[3]  ,TamSX3("NCS_VALOR")[1]   ,TamSX3("NCS_VALOR")[2]   ,PesqPict("NCS","NCS_VALOR")} ,;     //Total Contrato" 
 		/*"Moeda"            */ {STR0010                 , "MOEDA"         ,"C"                     ,10                       ,0                        , "@!" }                       ,; //
		/*"BASIS"            */ {STR0011                 , "COMPBASIS"     ,TamSX3("N7C_CODCOM")[3] ,TamSX3("N7C_CODCOM")[1]  ,TamSX3("N7C_CODCOM")[2]  ,PesqPict("N7C","N7C_CODCOM")} ,;
		/*"Vlr.Med.Basis"    */ {STR0012                 , "VLRMEDBASI"    ,TamSX3("N7C_VLRCOM")[3] ,TamSX3("N7C_VLRCOM")[1]  ,TamSX3("N7C_VLRCOM")[2]  ,PesqPict("N7C","N7C_VLRCOM")} ,;       //
		/*"Un.Med.Basis"     */ {STR0013                 , "UNMEDBASIS"    ,TamSX3("N7C_UMCOM")[3]  ,TamSX3("N7C_UMCOM")[1]   ,TamSX3("N7C_UMCOM")[2]   ,PesqPict("N7C","N7C_UMCOM")}  ,;       //
		/*NK8_CODPRO         */ {AgrTitulo("NK8_CODPRO") , "CODPRODUTO"    ,TamSX3("NK8_CODPRO")[3] ,TamSX3("NK8_CODPRO")[1]  ,TamSX3("NK8_CODPRO")[2]  ,PesqPict("NK8","NK8_CODPRO")} ,;      //
		/*B1_DESC            */ {AgrTitulo("B1_DESC")    , "DESCPRODUT"    ,TamSX3("B1_DESC")[3]    ,TamSX3("B1_DESC")[1]     ,TamSX3("B1_DESC")[2]     ,PesqPict("SB1","B1_DESC")}    ,;      //
		/*N7C_UMPROD         */ {AgrTitulo("N7C_UMPROD") , "UNMEDPROD"     ,TamSX3("N7C_UMPROD")[3] ,TamSX3("N7C_UMPROD")[1]  ,TamSX3("N7C_UMPROD")[2]  ,PesqPict("N7C","N7C_UMPROD")} ,;      //
		/*N8U_QTDCTR         */ {AgrTitulo("N8U_QTDCTR") , "QTDXCTRFUT"    ,TamSX3("N8U_QTDCTR")[3] ,TamSX3("N8U_QTDCTR")[1]  ,TamSX3("N8U_QTDCTR")[2]  ,PesqPict("N8U","N8U_QTDCTR")} ,;      //
		/*N7C_CODCOM         */ {AgrTitulo("N7C_CODCOM") , "COMPONENTE"    ,TamSX3("N7C_CODCOM")[3] ,TamSX3("N7C_CODCOM")[1]  ,TamSX3("N7C_CODCOM")[2]  ,PesqPict("N7C","N7C_CODCOM")} ,; //
        /*NK7_DESCRI         */ {AgrTitulo("NK7_DESCRI") , "NOMECOMP"      ,TamSX3("NK7_DESCRI")[3] ,TamSX3("NK7_DESCRI")[1]  ,TamSX3("NK7_DESCRI")[2]  ,PesqPict("NK7","NK7_DESCRI")} ,; //
        /*NK0_DATVEN         */ {AgrTitulo("NK0_DATVEN") , "DATVENCTO"     ,TamSX3("NK0_DATVEN")[3] ,TamSX3("NK0_DATVEN")[1]  ,TamSX3("NK0_DATVEN")[2]  ,PesqPict("NK0","NK0_DATVEN")} ,;   //
		/*NCS_BOLSA          */ {AgrTitulo("NCS_BOLSA")  , "BOLSA"         ,TamSX3("NCS_BOLSA")[3]  ,TamSX3("NCS_BOLSA")[1]   ,TamSX3("NCS_BOLSA")[2]   ,PesqPict("NCS","NCS_BOLSA")}  ,;      //
        /*NK0_VMESAN         */ {AgrTitulo("NK0_VMESAN") , "VCTMESAN"     ,TamSX3("NK0_VMESAN")[3]  ,TamSX3("NK0_VMESAN")[1]  ,TamSX3("NK0_VMESAN")[2]  ,PesqPict("NK0","NK0_VMESAN")}  ;      //
        }     //

	aIdx    := { {"", "INDICE"}, {"", "DATVENCTO"}, {"", "BOLSA"}, {"", "VCTMESAN"}, {"", "CODPRODUTO"}, {"", "COMPONENTE"} }	
    aAdd(_aIdxBrw,STR0027) //"Índice"
    aAdd(_aIdxBrw,STR0028) //"Dat. Vencimento"
    aAdd(_aIdxBrw,STR0029) //"Bolsa"
    aAdd(_aIdxBrw,STR0030) //"Mês/Ano"
    aAdd(_aIdxBrw,STR0031) //"Cód. Produto"
    aAdd(_aIdxBrw,STR0032) //"Componente"
    Processa({|| _cTabCtr := MontaTabel(_aFieldsQry, aIdx )},STR0002)//"Construindo layout da tela."
	Processa({|| fLoadDados(_cFiltro)},STR0003) //"Carregando a tabela de dados."

	//Criando o Browser de Visualização
	_oBrowse := FWMBrowse():New()
    _oBrowse:SetAlias(_cTabCtr)
    _oBrowse:SetDescription( STR0001 )//Análise de Exposição de Contratos Futuros
    if FWIsInCallStack("OGA700")
        cFiltroDef 	:= iIf( !Empty( cProduto ), "CODPRODUTO ='"+cProduto+"'", "" )
        _oBrowse:SetFilterDefault( cFiltroDef )
    endif
    _oBrowse:DisableDetails()
    _oBrowse:SetMenuDef( "OGC180" ) //verifica para coloca as opções de menu aqui - fixar, contrato, etc.
    _oBrowse:SetProfileID("OGC180BRW1")
	
    For nCont := 1  to Len(_aCpsBrowCt) //desconsiderar STATUS e Tipo
        If !_aCpsBrowCt[nCont][2] $ "NCS_FILIAL|NCS_CODIGO" 
        	_oBrowse:AddColumn( {_aCpsBrowCt[nCont][1]  , &("{||"+_aCpsBrowCt[nCont][2]+"}") ,_aCpsBrowCt[nCont][3],_aCpsBrowCt[nCont][6],iif(_aCpsBrowCt[nCont][3] == "N",2,1),_aCpsBrowCt[nCont][4],_aCpsBrowCt[nCont][5],.f.} )
        EndIf
        If !_aCpsBrowCt[nCont][2] $ "NCS_FILIAL|NCS_CODIGO" 
	       	aADD(aFilBrowCtr,  {_aCpsBrowCt[nCont][2], _aCpsBrowCt[nCont][1], _aCpsBrowCt[nCont][3], _aCpsBrowCt[nCont][4], _aCpsBrowCt[nCont][5], _aCpsBrowCt[nCont][6] } )
       	EndIf
        
    Next nCont

    _oBrowse:SetFieldFilter(aFilBrowCtr)
    _oBrowse:Activate()

Return .T.

Static Function fMntFiltro()
	Local cFiltro := ""
	cFiltro +=  " "
return cFiltro


/*/{Protheus.doc} Pergunta FKEY-F12 - OGC180F12
@author carlos.augusto/marcelo.ferrari
@since 09/11/2018
@version 1.0
@return ${return}, ${return_description}
@param aCpsBrow, array, descricao
@param aIdxTab, array, descricao
@type function
/*/
Function OGC180F12()
   OGC180PERG(.T.)
	//-- Carrega dados e cria arquivos temporários
	//Processa( { || fLoadDados() }, STR0003)
	//_oBrowse:UpdateBrowse()
Return

Function OGC180PERG(lPergunta)
	// Abre a tela de parâmetros de perguntas
	Pergunte("OGC1800001", lPergunta )
    _cBasis := MV_PAR01
	_cBasis := MV_PAR01
Return( _cBasis )


/*/{Protheus.doc} MontaTabel
@author carlos.augusto/marcelo.ferrari
@since 09/11/2018
@version 1.0
@return ${return}, ${return_description}
@param aCpsBrow, array, descricao
@param aIdxTab, array, descricao
@type function
/*/
Static Function MontaTabel(aCpsBrow, aIdxTab)
    Local nCont 	:= 0
    Local cTabela	:= ''
	Local aStrTab 	:= {}	//Estrutura da tabela

    //-- Busca no aCpsBrow as propriedades para criar as colunas
    For nCont := 1 to Len(aCpsBrow)
        aADD(aStrTab,{aCpsBrow[nCont][2], aCpsBrow[nCont][3], aCpsBrow[nCont][4], aCpsBrow[nCont][5] })
    Next nCont
   	//-- Tabela temporaria de pendencias
   	cTabela  := GetNextAlias()
   	//-- A função AGRCRTPTB está no fonte AGRUTIL01 - Funções Genericas
    __oArqTemp := AGRCRTPTB(cTabela, {aStrTab, aIdxTab})
    
Return cTabela


/*/{Protheus.doc} fLoadDados
//Carrega os dados da Tabela Temporária
@author carlos.augusto/marcelo.ferrari
@since 09/11/2018
@version 1.0
@return ${return}, ${return_description}
@param cFiltro, characters, descricao
@type function
/*/
Function fLoadDados()
	Local cSql       := ""
	Local nVlrUnMedCtr := 0
	Local cDB := TcGetDB()
    Local cAliasQry := GetNextAlias()    
    Local nValor := 0

    Local cSqlFix  := "" 
    Local cAliasFix := "" 

    Local cSqlBasis   := ""
    Local cAliasBasis := "" 


	If cDb = 'MSSQL'
		cStrDt := "GETDATE()"
	ElseIf cDb =  "ORACLE"
		cStrDt := "TO_CHAR(SYSDATE, 'YYYYMMDD')"
	EndIf

	//limpa a tabela temporária
	DbSelectArea((_cTabCtr))
	ZAP
	     
	//monta o filtro padrão
	_cFiltro := fMntFiltro() //apropria filtro
	
	cSql := " SELECT NK0.NK0_INDICE INDICE,  "
    cSql +=     " NK0.NK0_DATVEN DATVENCTO, "
    cSql +=     " NK0.NK0_CODBOL BOLSA, "
    cSql +=     " NK0.NK0_VMESAN VCTMESAN, "  
	cSql +=     " ISNULL(NK0.NK0_MOEDA, 0) CODMOEDA, "   
    cSql +=     " NK0.NK0_CODPRO CODPRODUTO, "
	cSql +=     " ISNULL(SB1.B1_DESC, '') DESCPRODUT, "  
	cSql +=     " ISNULL(NK0.NK0_UM1PRO, '') UNMEDPROD, "
	cSql +=     " ISNULL(N7C.N7C_CODCOM, '') COMPONENTE, "
    cSql +=     " ISNULL(NK7.NK7_DESCRI, '') NOMECOMP, "
    cSql +=     " ISNULL(N7C.N7C_UMCOM, '') UNMEDCOMP, "          	   
	cSql +=     " ISNULL(NCS.NCS_SAFRA, '') SAFRA, "
	cSql +=     " ISNULL(NCS.NCS_QTDE, 0) QTDCTRFUT, "
	cSql +=     " CAST( SUM(NCS.NCS_VALOR * NCS.NCS_QTDE) / SUM(NCS.NCS_QTDE) AS NUMERIC(18, 6)) VLRMEDCTFT, "
	cSql +=     " ISNULL(N8U.N8U_QTDCTR, 0) QTDXCTRFUT,     "
	cSql +=     " ISNULL(N8U.N8U_UMCTR, '') UNMEDCTRFT, "
	cSql +=     " SUM(N79NEG.N79_QTDNGC) QTDNEGOCIO "
    cSql += " FROM " + RetSqlName("NK0") + " NK0 "
    //### Busca dados do cadastro de produto x componenetes de preço(NK8)  pelo indice 
    cSql += " INNER JOIN " + RetSqlName("NK8") + " NK8 ON NK8_FILIAL = '"+ xFilial("NK8") + "' "
    cSql +=     " AND NK8.NK8_CODIDX = NK0.NK0_INDICE "
    cSql +=     " AND NK8.NK8_CODPRO = NK0.NK0_CODPRO "
    cSql +=     " AND NK8.D_E_L_E_T_ = '' "
    //### Busca dados dos componentes de preço(NK7)  pelo componente do indice 
    cSql += " INNER JOIN " + RetSqlName("NK7") + " NK7 ON NK7_FILIAL = NK8_FILIAL "
    cSql +=     " AND NK7.NK7_CODCOM = NK8.NK8_CODCOM "
    cSql +=     " AND NK7.D_E_L_E_T_ = '' "
    //###  Busca dados dos indices de bolsa de referencia(N8U)  pela bolsa do indice 
    cSql += " INNER JOIN " + RetSqlName("N8U") + " N8U ON N8U_FILIAL = '"+ xFilial("N8U") + "' "
    cSql +=     " AND N8U.N8U_CODBOL = NK0.NK0_CODBOL "
    cSql +=     " AND N8U.N8U_CODPRO = NK0.NK0_CODPRO "
    cSql +=     " AND N8U.D_E_L_E_T_ = '' "
    //###  Busca dados do cadastro de produto(SB1) do indice 
    cSql += " INNER JOIN " + RetSqlName("SB1") + " SB1 ON SB1.B1_FILIAL = '"+ xFilial("SB1") + "' "
	cSql +=     " AND SB1.B1_COD = NK0.NK0_CODPRO "
	cSql +=     " AND SB1.D_E_L_E_T_ = '' "
    //###  Busca dados dos contratos futuros(NCS) pelo indice 
    cSql += " INNER JOIN  " + RetSqlName("NCS") + " NCS ON NCS.NCS_FILIAL = '"+ xFilial("NCS") + "' "
	cSql +=     " AND NCS.NCS_TICKER = NK0.NK0_INDICE  "
	cSql +=     " AND NCS.NCS_COMMOD = NK0.NK0_CODPRO "
	cSql +=     " AND NCS.D_E_L_E_T_ = '' "
    //###  Busca dados dos componentes de negocio(N7C) pelo indice  
    cSql += " LEFT JOIN " + RetSqlName("N7C") + " N7C ON N7C.N7C_FILIAL = '"+ xFilial("N7C") + "' "
    cSql +=     " AND N7C.N7C_CODIDX = NK0.NK0_INDICE "
    cSql +=     " AND N7C.N7C_CODCOM = NK8.NK8_CODCOM "
    cSql +=     " AND N7C.D_E_L_E_T_ = '' "
    //###  Busca dados dos registros de negocio(N79) pelo negocio que tem o indice e seja tipo negocio a fixar 
    cSql += " LEFT JOIN " + RetSqlName("N79") + " N79NEG ON N79NEG.N79_FILIAL = N7C.N7C_FILIAL "
    cSql +=     " AND  N79NEG.D_E_L_E_T_ = '' AND N79NEG.N79_CODNGC = N7C.N7C_CODNGC "
    cSql +=     " AND N79NEG.N79_VERSAO = N7C.N7C_VERSAO  "
    //###  Filtro Where 
    cSql += " WHERE NK0.NK0_FILIAL = '"+ xFilial("NK0") + "' "
    cSql +=     " AND (NK0.NK0_DATVEN >= GETDATE() OR NK0.NK0_DATVEN = '') "
	cSql +=     " AND N79NEG.N79_TIPO='1' AND N79NEG.N79_STATUS='3' " //NEGOCIO COMPLETO
    cSql +=     " AND N79NEG.N79_TIPFIX = '2'  " //A FIXAR
    //###  GROUP BY
    cSql += " GROUP BY NK0.NK0_INDICE, "
    cSql +=     " NK0.NK0_DATVEN, "
    cSql +=     " NK0.NK0_CODBOL, "
    cSql +=     " NK0.NK0_VMESAN, "
	cSql +=     " NK0.NK0_CODPRO, "
	cSql +=     " NK0.NK0_UM1PRO, "
	cSql +=     " N8U.N8U_UMCTR, "
    cSql +=     " N7C.N7C_CODCOM, "
    cSql +=     " NK7.NK7_DESCRI, "
    cSql +=     " N7C.N7C_UMCOM, "
    cSql +=     " NK0.NK0_MOEDA, "
    cSql +=     " SB1.B1_DESC, "  
	cSql +=     " NCS.NCS_SAFRA, "
	cSql +=     " N8U.N8U_QTDCTR,  "
	cSql +=     " NCS.NCS_QTDE "

    cSql := ChangeQuery(cSql)
	dbUseArea(.T.,"TOPCONN",TCGenQry(,,cSql),cAliasQry,.F.,.T.)

    dbSelectArea(cAliasQry)
	(cAliasQry)->(dbGoTop())
	While (cAliasQry)->(!Eof()) 
        Reclock(_cTabCtr, .T.)
        (_cTabCtr)->INDICE      := (cAliasQry)->INDICE 
        (_cTabCtr)->DATVENCTO   := StoD((cAliasQry)->DATVENCTO)
        (_cTabCtr)->BOLSA       := (cAliasQry)->BOLSA
        (_cTabCtr)->VCTMESAN    := (cAliasQry)->VCTMESAN
        (_cTabCtr)->SAFRA       := (cAliasQry)->SAFRA 
        (_cTabCtr)->QTDCTRFUT   := (cAliasQry)->QTDCTRFUT
        (_cTabCtr)->VLRMEDCTFT  := (cAliasQry)->VLRMEDCTFT
        (_cTabCtr)->CODPRODUTO  := (cAliasQry)->CODPRODUTO
        (_cTabCtr)->DESCPRODUT  := (cAliasQry)->DESCPRODUT
        (_cTabCtr)->UNMEDPROD   := (cAliasQry)->UNMEDPROD 
        (_cTabCtr)->QTDXCTRFUT  := (cAliasQry)->QTDXCTRFUT
        (_cTabCtr)->UNMEDCTRFT  := (cAliasQry)->UNMEDCTRFT
        (_cTabCtr)->COMPONENTE  := (cAliasQry)->COMPONENTE
        (_cTabCtr)->NOMECOMP    := (cAliasQry)->NOMECOMP  
        (_cTabCtr)->UNMEDCOMP   := (cAliasQry)->UNMEDCOMP 
        (_cTabCtr)->CODMOEDA    := (cAliasQry)->CODMOEDA
        (_cTabCtr)->QTDNEGOCIO  := (cAliasQry)->QTDNEGOCIO

        /////// padroniza valores //////
        (_cTabCtr)->QTCTNEGOCI  := 0 //(cAliasQry)->QTCTNEGOCI
        (_cTabCtr)->QTDCTRAFIX  := 0  
        (_cTabCtr)->QTDCOMPFIX  := 0 //SUM(ISNULL(NNEG.QTDNEGOCIO, 0))  - SUM(ISNULL(N7C_QTAFIX, 0)) QTDCOMPFIX,
        (_cTabCtr)->TTVLRFIX    := 0
        (_cTabCtr)->COMPBASIS   := ''
        (_cTabCtr)->UNMEDBASIS  := ''
        (_cTabCtr)->VLRMEDBASI  := 0 
        (_cTabCtr)->VLRTOTCTFT := 0
        (_cTabCtr)->VLCTFUTBAS := 0

        //Busca os dados da fixação do negocio 
        cAliasFix := GetNextAlias()  
        cSqlFix := " SELECT N79.N79_STATUS,N79.N79_TIPO,SUM(N7C.N7C_QTAFIX) N7C_QTAFIX, SUM(N7C.N7C_QTDCTR)  N7C_QTDCTR "
        cSqlFix += " FROM " + RetSqlName("N7C") + " N7C "
        cSqlFix += " INNER JOIN " + RetSqlName("N79") + " N79 ON N79.D_E_L_E_T_ = '' AND N79.N79_FILIAL = N7C.N7C_FILIAL "
        cSqlFix +=      " AND N79.N79_CODNGC = N7C.N7C_CODNGC AND N79.N79_VERSAO = N7C.N7C_VERSAO "
        cSqlFix += " INNER JOIN N79T10 N79NEG ON N79NEG.N79_FILIAL = N79.N79_FILIAL " //PARA GARANTIR QUE O NEGOCIO ESTA ATIVO E NÃO FOI CANCELADO
        cSqlFix +=      " AND N79NEG.D_E_L_E_T_ = '' AND N79NEG.N79_CODCTR = N79.N79_CODCTR "
        cSqlFix +=      " AND N79NEG.N79_STATUS = '3' AND N79NEG.N79_TIPO = '1' AND N79NEG.N79_TIPFIX = '2' "
        cSqlFix += " WHERE N7C.N7C_FILIAL = '"+ xFilial("N7C") + "' AND N7C.N7C_CODIDX = '" + (cAliasQry)->INDICE + "' "
        cSqlFix +=      " AND N7C.N7C_CODCOM = '" + (cAliasQry)->COMPONENTE + "' "
        cSqlFix +=      " AND N7C.D_E_L_E_T_ = '' "
        cSqlFix +=      " AND N79.N79_TIPO <> '1' " 
        cSqlFix +=      " AND N79.N79_TIPFIX = '1' " //FIXO
        cSqlFix += " GROUP BY N79.N79_STATUS,N79.N79_TIPO "
        cSqlFix := ChangeQuery(cSqlFix)
        dbUseArea(.T.,"TOPCONN",TCGenQry(,,cSqlFix),cAliasFix,.F.,.T.)

        dbSelectArea(cAliasFix)
        (cAliasFix)->(dbGoTop())
        While (cAliasFix)->(!Eof()) 

            If (cAliasFix)->N79_TIPO == '2'  //FIXAÇÕES 
                (_cTabCtr)->QTCTNEGOCI  += (cAliasFix)->N7C_QTDCTR //qtd de contrato futuro informado na fixação do negocio
                If (cAliasFix)->N79_STATUS $ '1|2'  //FIXAÇÕES PENDENTE OU TRABALHANDO
                    (_cTabCtr)->QTDCTRAFIX  += (cAliasFix)->N7C_QTDCTR  //quantidade de contrato futuro ainda não fixado.
                EndIf
            ElseIF (cAliasFix)->N79_TIPO == '3' .AND. (cAliasFix)->N79_STATUS == '3' //CANCELAMENTOS DA FIXAÇÃO COMPLETAS
                (_cTabCtr)->QTCTNEGOCI  -= (cAliasFix)->N7C_QTDCTR
            EndIf

            (cAliasFix)->( DbSkip() )
        EndDo
        (cAliasFix)->( dbCloseArea() )

        //saldo contrato sem cobertura 
        (_cTabCtr)->QTDCTRSHED := (_cTabCtr)->QTDCTRFUT - (_cTabCtr)->QTDCTRAFIX

        //Calcula a quantidade total volume na und. medida do contrato de futuro
        (_cTabCtr)->TTQTDCTR := (_cTabCtr)->QTDCTRFUT * (_cTabCtr)->QTDXCTRFUT

        //volume dos contratos sem cobertura na unidade de medida do contrato de futuro
        (_cTabCtr)->QTDCOMPFIX  := (_cTabCtr)->QTDCTRAFIX * (_cTabCtr)->QTDXCTRFUT

        //saldo de contratos sem cobertura na unidade de medida do contrato de futuro
        (_cTabCtr)->QTDCOMSHED =  (_cTabCtr)->TTQTDCTR - (_cTabCtr)->QTDCOMPFIX	
        

        cAliasBasis := GetNextAlias()    
        // Busca dados do COMPONENTE BASIS nos contratos/NEGOCIOS que usa o indice do contrato futuro 
        cSqlBasis :=    " SELECT  ISNULL(N7CBAS.N7C_CODCOM,'') COMPBASIS, "
		cSqlBasis +=            " ISNULL(N7CBAS.N7C_UMCOM,'') UNMEDBASIS, "
		cSqlBasis +=            " ISNULL(SUM(N7CBAS.N7C_QTAFIX * N7CBAS.N7C_VLRCOM) / SUM(N7CBAS.N7C_QTAFIX),0) VLRMEDBASIS " // Valor médio do Basis FIXADO  
		cSqlBasis +=    " FROM "  + RetSqlName("N7C") + " N7C "
		cSqlBasis +=    " INNER JOIN "  + RetSqlName("N7C") + " N7CBAS ON N7CBAS.N7C_FILIAL = N7C.N7C_FILIAL "
		cSqlBasis +=        " AND N7CBAS.N7C_CODNGC = N7C.N7C_CODNGC "
		cSqlBasis +=        " AND N7CBAS.N7C_VERSAO = N7C.N7C_VERSAO "
		cSqlBasis +=        " AND N7CBAS.N7C_CODCOM = '"+ _cBasis + "'  " //CODIGO COMPONENTE BASIS
		cSqlBasis +=        " AND N7CBAS.N7C_QTAFIX > 0 "
		cSqlBasis +=        " AND N7CBAS.N7C_VLRCOM <> 0 "
		cSqlBasis +=        " AND N7CBAS.D_E_L_E_T_ = ' ' "   
        cSqlBasis +=    " INNER JOIN "  + RetSqlName("N79") + " N79 ON N79.N79_FILIAL = N7C.N7C_FILIAL
        cSqlBasis +=        " AND N79.D_E_L_E_T_ = '' AND N79.N79_CODNGC = N7C.N7C_CODNGC
        cSqlBasis +=        " AND N79.N79_STATUS = '3' AND N79.N79_TIPO <> '1' AND N79.N79_TIPFIX = '1' 
        cSqlBasis += " INNER JOIN N79T10 N79NEG ON N79NEG.N79_FILIAL = N79.N79_FILIAL " //PARA GARANTIR QUE O NEGOCIO ESTA ATIVO E NÃO FOI CANCELADO
        cSqlBasis +=      " AND N79NEG.D_E_L_E_T_ = '' AND N79NEG.N79_CODCTR = N79.N79_CODCTR "
        cSqlBasis +=      " AND N79NEG.N79_STATUS = '3' AND N79NEG.N79_TIPO = '1' AND N79NEG.N79_TIPFIX = '2' "
		cSqlBasis +=    " WHERE N7C.N7C_FILIAL = '"+ xFilial("N7C") + "' "
        cSqlBasis +=        " AND N7C.N7C_CODCOM = '" + (cAliasQry)->COMPONENTE + "' "
        cSqlBasis +=        " AND N7C.N7C_CODIDX = '" + (cAliasQry)->INDICE + "' "
        cSqlBasis +=        " AND N7C.D_E_L_E_T_ = '' "
		cSqlBasis +=        " GROUP BY N7CBAS.N7C_CODCOM , "
		cSqlBasis +=                 " N7CBAS.N7C_UMCOM "

        cSqlBasis := ChangeQuery(cSqlBasis)
	    dbUseArea(.T.,"TOPCONN",TCGenQry(,,cSqlBasis),cAliasBasis,.F.,.T.)

        dbSelectArea(cAliasBasis)
        (cAliasBasis)->(dbGoTop())
        If (cAliasBasis)->(!Eof()) 
            (_cTabCtr)->COMPBASIS   := (cAliasBasis)->COMPBASIS
            (_cTabCtr)->UNMEDBASIS  := (cAliasBasis)->UNMEDBASIS
            (_cTabCtr)->VLRMEDBASI  := (cAliasBasis)->VLRMEDBASI 
        EndIF
        (cAliasBasis)->(dbCloseArea())
        
        //Converter o Valor médio Unitário da commoditie para valor unitário na unidade do contrato
		//Exemplo    Commoditie: 3,65/BU   |   Contrato: 22000Kg
        
        //VLRMEDCTFT  Valor medio contrato futuro
        //Converter para unidade de medida da unidade do contrato futuro
        nVlrUnMedCtr := iif(Empty((_cTabCtr)->VLRMEDCTFT),0,(_cTabCtr)->VLRMEDCTFT)
        nVlrTTCtr := iif(Empty((_cTabCtr)->TTQTDCTR),0,(_cTabCtr)->TTQTDCTR)

        //VLRMEDBASI   Valor medio contrato futuro
        //Converter para unidade de medida da o contrato futuro
        nVlrUnMedBas := OGX700UMVL( (_cTabCtr)->VLRMEDBASI, (_cTabCtr)->UNMEDBASIS, (_cTabCtr)->UNMEDCOMP, (_cTabCtr)->CODPRODUTO ) 

        //Calcula o Valor base para contratos futuros na respectiva unidade de medida
        (_cTabCtr)->VLCTFUTBAS =  iif(Empty(nVlrUnMedCtr),0,nVlrUnMedCtr) + iif(Empty(nVlrUnMedBas),0,nVlrUnMedBas) 

        nVlrMedCFt   := OGX700UMVL( (_cTabCtr)->VLCTFUTBAS, (_cTabCtr)->UNMEDCOMP, (_cTabCtr)->UNMEDCTRFT, (_cTabCtr)->CODPRODUTO )

        //Calcula o valor total dos contratos de Futuro
        nValor := nVlrMedCFt * nVlrTTCtr
        (_cTabCtr)->VLRTOTCTFT := round( nValor , TamSX3("N7C_VLRCOM")[2] )

        //Busca a descrição da moeda
        (_cTabCtr)->MOEDA = AGRMVMOEDA( (_cTabCtr)->CODMOEDA )

	    (_cTabCtr)->(MsUnlock())
        (cAliasQry)->( DbSkip() )

	EndDo
	(cAliasQry)->(dbCloseArea())

Return(.t.)


/*/{Protheus.doc} MenuDef
@author carlos.augusto/marcelo.ferrari
@since 09/11/2018
@version 1.0
@return ${return}, ${return_description}

@type function
/*/
Static Function MenuDef()
	Local aRotina := {}

	ADD OPTION aRotina TITLE STR0017   ACTION "OGC180PESQ()"       OPERATION 1 ACCESS 0 //"Pesquisar"	
	
Return aRotina

Function OGC180PESQ()
local oDlgPesq, oOrdem, oChave, oBtOk, oBtCan, oBtPar
Local cOrdem
Local cChave := Space(255)
Local nOrdem := 1
Local nOpcao := 0

DEFINE MSDIALOG oDlgPesq TITLE STR0026 FROM 00,00 TO 100,500 PIXEL //Pesquisa
  @ 005, 005 COMBOBOX oOrdem VAR cOrdem ITEMS _aIdxBrw SIZE 210,08 PIXEL OF oDlgPesq ON CHANGE nOrdem := oOrdem:nAt
  @ 020, 005 MSGET oChave VAR cChave SIZE 210,08 OF oDlgPesq PIXEL
  DEFINE SBUTTON oBtOk  FROM 05,218 TYPE 1 ACTION (nOpcao := 1, oDlgPesq:End()) ENABLE OF oDlgPesq PIXEL
  DEFINE SBUTTON oBtCan FROM 20,218 TYPE 2 ACTION (nOpcao := 0, oDlgPesq:End()) ENABLE OF oDlgPesq PIXEL
  DEFINE SBUTTON oBtPar FROM 35,218 TYPE 5 WHEN .F. OF oDlgPesq PIXEL

ACTIVATE MSDIALOG oDlgPesq CENTER

If nOpcao == 1
  cChave := AllTrim(cChave)
  (_cTabCtr)->(dbSetOrder(nOrdem)) 
  (_cTabCtr)->(dbSeek(cChave))
ElseIf nOpcao == 0
  (_cTabCtr)->(dbSetOrder(1)) 
  (_cTabCtr)->(dbGoTop())
Endif

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} OGC180MSGROTINA
Função para verificar se a rotina de controle de risco está habilitada.
@author  rafael.voltz
@since   04/12/2019
@version 1.0
/*/
//-------------------------------------------------------------------
Function OGC180VLDROTINA()   
    
    If !SuperGetMv('MV_AGRO041', , .F.) 
        AGRHELP(STR0033, STR0034, STR0035) //"Esta rotina não está habilitada para utilização." "Verifique o parâmetro MV_AGRO041."
        return .f.
    EndIf

Return .T.
