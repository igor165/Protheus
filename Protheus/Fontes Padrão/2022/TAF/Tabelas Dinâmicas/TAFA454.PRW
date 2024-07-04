#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "TAFA454.CH"
//-------------------------------------------------------------------
/*/{Protheus.doc} TAFAXXX
Cadastro MVC dos campos fiscais complementares

@author Rafael Völtz
@since 03/10/2016
@version 1.0

/*/
//-------------------------------------------------------------------
Function TAFA454()
Local   oBrw        :=  FWmBrowse():New()

oBrw:SetDescription(STR0001)    //"Campos complementares fiscais
oBrw:SetAlias( 'T54')
oBrw:SetMenuDef( 'TAFA454' )
T54->(DbSetOrder(1))
oBrw:Activate()

Return
//-------------------------------------------------------------------
/*/{Protheus.doc} MenuDef
Funcao generica MVC com as opcoes de menu

@author Rafael Völtz
@since 03/10/2016
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function MenuDef()
Return XFUNMnuTAF( "TAFA454" ,,,,.T. )
//-------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
Funcao generica MVC do model

@return oModel - Objeto do Modelo MVC

@author Rafael Völtz
@since 03/10/2016
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function ModelDef()
Local oStruT54  :=  FWFormStruct( 1, 'T54' )
Local oModel    :=  MPFormModel():New( 'TAFA454' )

oModel:AddFields('MODEL_T54', /*cOwner*/, oStruT54)
oModel:GetModel('MODEL_T54'):SetPrimaryKey({'T54_FILIAL','T54_ID'})

Return oModel
//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
Funcao generica MVC do View

@return oView - Objeto da View MVC

@author Rafael Völtz
@since 03/10/2016
@version 1.0

/*/
//-------------------------------------------------------------------
Static Function ViewDef()
Local   oModel      :=  FWLoadModel( 'TAFA454' )
Local   oStruT54    :=  FWFormStruct( 2, 'T54' )
Local   oView       :=  FWFormView():New()

oStruT54:RemoveField('T54_ID')

oView:SetModel( oModel )
oView:AddField( 'VIEW_T54', oStruT54, 'MODEL_T54' )

oView:EnableTitleView( 'VIEW_T54', STR0001 )  //Campos complementares fiscais
oView:CreateHorizontalBox( 'FIELDST54', 100 )
oView:SetOwnerView( 'VIEW_T54', 'FIELDST54' )

Return oView

//-------------------------------------------------------------------
/*/{Protheus.doc} FAtuCont

Rotina para carga e atualização da tabela autocontida.

@Param		nVerEmp	-	Versão corrente na empresa
			nVerAtu	-	Versão atual ( passado como referência )

@Return	aRet		-	Array com estrutura de campos e conteúdo da tabela

@Author	Rafael Völtz
@Since		13/10/2016
@Version	1.0
/*/
//-------------------------------------------------------------------
Static Function FAtuCont( nVerEmp, nVerAtu )

Local aHeader	:=	{}
Local aBody	:=	{}
Local aRet		:=	{}

nVerAtu := 1018

If nVerEmp < nVerAtu
	aAdd( aHeader, "T54_FILIAL" )
	aAdd( aHeader, "T54_ID" )
	aAdd( aHeader, "T54_CHAVE" )
	aAdd( aHeader, "T54_TPDADO" ) // char 1 (N - Numérico, C - Caracter, D - Data, L - Lógico)
	aAdd( aHeader, "T54_TITULO" ) // char 12	
	aAdd( aHeader, "T54_DESCRI" ) // char 25
	aAdd( aHeader, "T54_PICTUR" ) // char 45
	aAdd( aHeader, "T54_CPADR" )  // char 06
	aAdd( aHeader, "T54_COMBO" )  // char 128
	aAdd( aHeader, "T54_TAMANH" )  // N 6
	aAdd( aHeader, "T54_DECIMA" )  // N 2
	aAdd( aHeader, "T54_FVALID" )  // CHAR 30	
	aAdd( aHeader, "T54_STRHLP" ) // char 11

	If AliasInDic("T54")
		//GIA-ST		    
		aAdd( aBody, { "", "8ad7dc68-9c03-7058-530b-1ce482321f93",  "VLR_REPASSE_ICMS_COMB",         "N", "STR0002","STR0003", "@R 9999999999999.99", "", "", "16", "2", "", "TAFA4560002"} ) //STR0002 - "ICMS Com Ref"     STR0003 - "Rep. ICMS Comb. Refinaria"		
		aAdd( aBody, { "", "6c4eb482-2c86-807f-9b2d-e32641ec3b93",  "VLR_REPASSE_ICMS_COMB_OUTROS",  "N", "STR0004","STR0005", "@R 9999999999999.99", "", "", "16", "2", "", "TAFA4560004"} ) //STR0005 - "ICMS Com Out"     STR0006 - "Rep. ICMS Comb. Outros"		
		
		//DIAP-AP
		aAdd( aBody, { "", "d67f2611-ff20-d767-95d9-2ec2fbfe81ae",  "VLR_IMP_FORA_PRAZO",            "N", "STR0006","STR0007", "@R 9999999999999.99", "", "", "16", "2", "", "TAFA4560005"} ) //STR0006 - "ICMS Imp For"     STR0007 - "ICMS Import. Fora do Prz"
		aAdd( aBody, { "", "f43dabaf-4bd1-4d2d-e527-b45ba16845a1",  "VLR_IMP_VENCIDO",	             "N", "STR0008","STR0009", "@R 9999999999999.99", "", "", "16", "2", "", "TAFA4560006"} ) //STR0008 - "ICMS Imp Ven"     STR0009 - "ICMS Import. Vencidos"
		aAdd( aBody, { "", "39a22006-5af3-212c-5c49-0bdba02e2a03",  "VLR_DIF_ALQ_ATV_FORA_PRAZO",    "N", "STR0010","STR0011", "@R 9999999999999.99", "", "", "16", "2", "", "TAFA4560007"} ) //STR0010 - "Dif Ativ Prz"     STR0011 - "Dif. Aliq. Ativo Fora Prz"
		aAdd( aBody, { "", "7e3130eb-dfa5-693b-b95c-2f90109d0764",  "VLR_DIF_ALQ_ATV_VENCIDO",       "N", "STR0012","STR0013", "@R 9999999999999.99", "", "", "16", "2", "", "TAFA4560008"} ) //STR0012 - "Dif Ativ Ven"     STR0013 - "Dif. Aliq. Ativo Vencido"
		aAdd( aBody, { "", "cdcde72e-fedd-11c1-51d5-c7094d0b986f",  "VLR_BENEFICIO_IMPORTACAO",      "N", "STR0014","STR0015", "@R 9999999999999.99", "", "", "16", "2", "", "TAFA4560009"} ) //STR0014 - "Benef. Imp."      STR0015 - "Benefício de Importação"
		aAdd( aBody, { "", "fa41a019-6578-6945-ead4-bebdef33d641",  "VLR_BENEFICIO_DIF_ALIQ_ATIVO", "N", "STR0016","STR0017", "@R 9999999999999.99", "", "", "16", "2", "", "TAFA4560010"} ) //STR0016 - "Benef. Dif."      STR0017 - "Benefício Dif. Alíquota"		
		aAdd( aBody, { "", "2e3776d3-81eb-768d-2b13-adddf64544b0",  "VLR_USO_FORA_PRAZO",            "N", "STR0018","STR0019", "@R 9999999999999.99", "", "", "16", "2", "", "TAFA4560012"} ) //STR0018 - "Dif Uso Fora"     STR0019 - "Dif Aliq Uso/Cons Fora Prz"
		aAdd( aBody, { "", "7bbaf803-e4cc-7d3d-9c74-2a2166a92995",  "VLR_USO_VENCIDO",	             "N", "STR0020","STR0021", "@R 9999999999999.99", "", "", "16", "2", "", "TAFA4560013"} ) //STR0020 - "Dif Uso Venc"      STR0021 - "Dif Aliq Uso/Cons Venc"
				
		//DECLAN-RJ		
		aAdd( aBody, { "", "722e460f-428f-4069-81fb-c675d7451b79",  "IPI_ENTR_MAT_PR",	            "C", "STR0022","STR0023", "@!", "C1N2", "", "220", "", "", "TAFA4560014"} ) //STR0022 - "IPI Ent Mat Prim"   STR0023 - "IPI na Entrada de Matéria Prima"		
		aAdd( aBody, { "", "e7746c02-3df6-d765-5635-1df011f758ae",  "IMPTO_ENTR_RETID",	            "C", "STR0024","STR0025", "@!", "C1N2", "", "220", "", "", "TAFA4560015"} ) //STR0024 - "ICMS Ret Entr"      STR0025 - "ICMS retido por substituição tributária"		
		aAdd( aBody, { "", "4e07e343-1c86-aa13-3237-e7037b696d53",  "IPI_NAO_INTEG_BC_ICMS_SAID",	"C", "STR0026","STR0027", "@!", "C1N2", "", "220", "", "", "TAFA4560016"} ) //STR0026 - "IPI ñ BC ICMS"      STR0027 - "IPI que não integra a BC de ICMS na Saída"
		aAdd( aBody, { "", "a7ac9fb9-fc98-0170-2b29-5e9fb86d496f",  "IPI_INTEG_BC_ICMS_SAID",	    "C", "STR0028","STR0029", "@!", "C1N2", "", "220", "", "", "TAFA4560017"} ) //STR0028 - "IPI BC ICMS"        STR0029 - "IPI que integra a BC de ICMS na Saída"		
		aAdd( aBody, { "", "873ceb4b-3378-ed03-320e-ce7e71eb54c1",  "IMPTO_SAID_RETID",	            "C", "STR0030","STR0031", "@!", "C1N2", "", "220", "", "", "TAFA4560018"} ) //STR0030 - "Impto Ret Sai"      STR0031 - "Imposto Retido Saídas"		
		
		//DPMP		
		aAdd( aBody, { "", "b9c6ca6a-bd2f-2e58-cf26-e61633832108",  "NAT_OPER_CONTA_ORDEM",	        "C", "STR0032","STR0033", "@!", "", "", "220", "", "", "TAFA4560019"} ) //STR0032 - "Nat.Vend.Cont.Ord"   STR0033 - "Nat. Operação de Venda de Conta e Ordem"	
		
		  
		/* EXEMPLOS PARA PREENCHIMENTO DE CADA TIPO DE CAMPO
		aAdd( aBody, { "", "c76a3ff4-f3ee-60ed-ef61-9eae9a9f5459",  "TESTE_DATA",    "D", "<string titulo>", "<string desc>", "",   "", "",            "8", "0", "", "Help do campo data"} ) 
		aAdd( aBody, { "", "a1d5679a-d6c0-bb19-04f7-f0c3a17f2897",  "TESTE_LÓGICO",  "L", "<string titulo>", "<string desc>", "",   "", "",            "1", "0", "", "Help do campo lógico"} ) 
		aAdd( aBody, { "", "002d5773-ffa8-cd00-1c62-80dd85703df2",  "TESTE_CHAR",    "C", "<string titulo>", "<string desc>", "@!", "", "",            "20","0", "", "Help do campo char"} )
		aAdd( aBody, { "", "41af3d36-3669-8ad7-9df9-e879e16549df",  "TESTE_COMBOBOX","C", "<string titulo>", "<string desc>", "",   "", "1=Sim;2=Não", "1", "0", "", "Help do campo ComboBox"} ) 
		*/
	EndIf
		
	aAdd( aRet, { aHeader, aBody } )
EndIf


Return( aRet )