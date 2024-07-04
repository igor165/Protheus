#INCLUDE "PROTHEUS.CH"
#INCLUDE "CTBXCUBA.CH"
//somente amarracao
STATIC lFWCodFil	:= .T.
STATIC _lChngQryD   := .T.
STATIC _cQueryDia   := NIL
STATIC _aQryCbDia   := {"","","","","","","","",""}
STATIC _lChngQryM   := .T.
STATIC _cQueryMes   := NIL
STATIC _aQryCbMes   := {"","","","","","","","",""}
Static _cThreadId := 0
Static _cFunExec := ""
// --------------------------------------------------------------------------------
// Declaracao da Classe Managerial_Cubes
// --------------------------------------------------------------------------------
//AMARRACAO
CLASS CtbManagerial_Cubes
// Declaracao das propriedades da Classe
DATA Code_Cube             //codigo do cubo
DATA Currency				//moeda
DATA Type_Of_Balance       //tipo de saldo
DATA Ctb_Date				//Data 
DATA Type_of_Movement		//D-ebito  -  C-redito
DATA Keyset_Levels			//Keyset_Levels --> Array contendo as chaves por nivel
//				                  ex: Nivel 1 - Conta Contabil
//				                      Nivel 2 - Centro de Custo
//				                      Nivel 3 - Item Contabil
//				                      Nivel 4 - Classe de Valor
//				                      { "11101001", "CC001", "IT001", "CL001", " ",  }
DATA Alias_Movement  		//alias da tabela de movimento
DATA Cube_DataGeneral      //oLstRec - lista de registro contendo dados gerais do cubo
DATA Cube_Struct           ////oLstRec - lista de registros contendo estrutura do cubo
DATA aDebExpKeyset_Levels  //expressao debito
DATA aCrdExpKeyset_Levels  //expressao credito
DATA aDebKeySet_Levels     //array conteudo ja macro executado expressao a debito
DATA aCrdKeySet_Levels     //array bconteudo ja macro executado expressao a debito

// Declara็ใo dos M้todos da Classe
METHOD New() CONSTRUCTOR
METHOD GetCode_Cube()            
METHOD SetCode_Cube(cCodeCube)
METHOD Get_DataGeneral()
METHOD Set_DataGeneral(oLstRec)
METHOD Get_Struct()
METHOD Set_Struct(oLstRec)
METHOD Get_Currency()
METHOD Set_Currency(cCurrency)
METHOD Get_Type_Of_Balance()
METHOD Set_Type_Of_Balance(cType_Of_Balance)
METHOD Get_Ctb_Date()
METHOD Set_Ctb_Date(dCtb_Date)
METHOD Get_Movement_Type()
METHOD Set_Movement_Type(cType_Movement)
METHOD Get_Keyset_Levels()
METHOD Set_Keyset_Levels(Keyset_Levels)
METHOD Get_Alias_Movement()
METHOD Set_Alias_Movement(cAlias_Movement)
METHOD Set_ExpKeyBuild(cType_of_Movement)
METHOD Set_BuildKey()
METHOD Set_Write_Balance(cType_of_Movement,cOperation,nValue)
METHOD GetCubeDate_Retrieve_Balance()
METHOD GetCubePeriod_Retrieve_Balances(Ctb_Date1,Ctb_Date2,lMovement)
METHOD Set_InitSemaforo()
METHOD Set_FinishSemaforo()  
                                         
ENDCLASS

// Cria็ใo do construtor, onde atribuimos os valores default 
// para as propriedades e retornamos Self
METHOD New() CLASS CtbManagerial_Cubes
Self:Cube_DataGeneral := NIL
Self:aDebExpKeyset_Levels := {}
Self:aCrdExpKeyset_Levels := {}
Self:aDebKeySet_Levels := {}
Self:aCrdKeySet_Levels := {}
Self:Cube_Struct := NIL
Self:Code_Cube := NIL
Self:Currency := NIL
Self:Type_Of_Balance := NIL
Self:Ctb_Date := NIL
Self:Type_of_Movement := NIL
Self:Keyset_Levels := {}
Self:Alias_Movement := NIL
Return Self


METHOD GetCode_Cube() CLASS CtbManagerial_Cubes
Return Self:Code_Cube

METHOD SetCode_Cube(cCodeCube) CLASS CtbManagerial_Cubes
Self:Code_Cube := cCodeCube
Return

METHOD Get_DataGeneral() CLASS CtbManagerial_Cubes
Return Self:Cube_DataGeneral

METHOD Set_DataGeneral(oLstRec) CLASS CtbManagerial_Cubes

If oLstRec:CountRecords() == 1
	Self:Cube_DataGeneral := oLstRec
	oLstRec:SetPosition(1)
	oLstRec:SetRecord()
	Self:SetCode_Cube(CT0->CT0_ID) 
Else
	Aviso(STR0001, STR0002, {"Ok"} )  //"Atencao"##"Erro ao setar o conjunto de registros referente ao cubo."
EndIf

Return 

METHOD Get_Struct() CLASS CtbManagerial_Cubes
Return Self:Cube_Struct

METHOD Set_Struct(oLstRec) CLASS CtbManagerial_Cubes
Self:Cube_Struct := oLstRec
Return 

METHOD Get_Currency() CLASS CtbManagerial_Cubes
Return Self:Currency

METHOD Set_Currency(cCurrency) CLASS CtbManagerial_Cubes
Self:Currency := cCurrency
Return 

METHOD Get_Type_Of_Balance() CLASS CtbManagerial_Cubes
Return Self:Type_Of_Balance

METHOD Set_Type_Of_Balance(cType_Of_Balance) CLASS CtbManagerial_Cubes
Self:Type_Of_Balance := cType_Of_Balance
Return 

METHOD Get_Ctb_Date() CLASS CtbManagerial_Cubes
Return Self:Ctb_Date

METHOD Set_Ctb_Date(dCtb_Date) CLASS CtbManagerial_Cubes
Self:Ctb_Date := dCtb_Date
Return 

METHOD Get_Movement_Type() CLASS CtbManagerial_Cubes
Return Self:Type_of_Movement

METHOD Set_Movement_Type(cType_Movement) CLASS CtbManagerial_Cubes
Self:Type_of_Movement := cType_Movement
Return 

METHOD Get_Keyset_Levels() CLASS CtbManagerial_Cubes
Return Self:Keyset_Levels

METHOD Set_Keyset_Levels(Keyset_Levels) CLASS CtbManagerial_Cubes
Self:Keyset_Levels := Keyset_Levels
Return 

METHOD Get_Alias_Movement() CLASS CtbManagerial_Cubes
Return Self:Alias_Movement

METHOD Set_Alias_Movement(cAlias_Movement) CLASS CtbManagerial_Cubes
Self:Alias_Movement := cAlias_Movement
Return 

/* ----------------------------------------------------------------------------


Classes para manipulacao do cubo
================================
Metodos
Write_Balance ---> Gravar Saldo
Retrieve_Balance --> Recuperar Saldo

Tabelas:
. Monthly_Balance  --> Saldo Mensal
. Balance_Diario --> Saldo Diario

Propriedades:
. Code_Cube --> Codigo do Cubo
. Currency --> Moeda
. Type_Of_Balance --> Tipo de Saldo 
. Date --> Data

. Type_of_Movement --> Tipo lancamento (Debito ou Credito)

. Value_Debit --> Valor Debito     //Ambos os saldos nao sao cumulativos ou seja somente possuem saldo do periodo
. Value_Credit --> Valor Credito
/* ARRAY Keyset_Levels
. Level_01  --> Nivel nn do Cubo //onde em cada nivel contera o campo entidade correspondente
. Level_02                       //por exemplo Conta Contabil
. Level_03                       //            Centro de Custo  
. Level_04                       //            Item Contabil
. Level_05                       //            Classe de Valor
. Level_06                       //            NIT (Colombia)
. Level_07                       //
. Level_08                       //
. Level_09                       //
. Level_10                       // as tabelas padroes conterao somente 9
. Level_11                       // os demais foram colocados para futuras implementacoes
. Level_12                       // 
. Level_13                       //
. Level_14                       //
. Level_15                       //

Escrita/Gravacao de saldos no Cubo:

Write_Balance --> Gravar o saldo
				Argumentos:
				Code_Cube --> Codigo do Cubo
				Currency --> Moeda
				Type_Of_Balance --> Tipo de Saldo 
				Date --> Data
				Type_of_Movement --> Tipo lancamento (Debito ou Credito)
				Operation --> Opera็ใo ( Somar ou Diminuir )
				Keyset Levels --> Array contendo as chaves por nivel
				                  ex: Nivel 1 - Conta Contabil
				                      Nivel 2 - Centro de Custo
				                      Nivel 3 - Item Contabil
				                      Nivel 4 - Classe de Valor
				                      { "11101001", "CC001", "IT001", "CL001" }

Regras :
- Codigo do Cubo sera o id da entidade (CT0->CT0_ID)
- Criar semaforo para chave completa
- Se nao existir na tabela de saldos diarios incluir novo registro
- Se nao existir na tabela de saldos mensais incluir novo registro
- Somar ou diminuir nos campos debito ou credito nas 2 tabelas
- Liberar semaforo para chave completa

chave completa
Filial+Codigo Cubo+Moeda+Ultima Data do Mes+Nivel01....Nivelnn
Filial+Codigo Cubo+Moeda+Data+Nivel01....Nivelnn

Recupera็ใo de Dados do Cubo:

Balance_on_Date  --> Saldo na Data

						argumentos:
						Code_Cube --> Codigo do Cubo
						Currency --> Moeda
						Date --> Date
						Type_of_Balance --> Tipo de Saldo

						Keyset Levels --> Array contendo as chaves por nivel
						                  ex: Nivel 1 - Conta Contabil
						                      Nivel 2 - Centro de Custo
						                      Nivel 3 - Item Contabil
						                      Nivel 4 - Classe de Valor
						                      { "11101001", "CC001", "IT001", "CL001" }
Regras :

	Se data for ultimo dia do mes:
	- Somar todos os saldos mensais menor ou igual a data de acordo as informacoes fornecidas

	Se data NAO for ultimo dia do mes:
	- Somar todos os saldos mensais anteriores a data de acordo as informacoes fornecidas
	- Acrescentar a Soma de todos os saldos diarios ate a data fornecida

Retorno:
	- Valor do saldo na data na forma de array : { Valor Debito, Valor Credito }
	         // se nao existir traz 0 (zero) nas 2 colunas


Balances_for_Period --> Saldos por periodo

Regra:
-Diferenca entre data(1) e data(2) de saldos na data
--->para a checkagem se isto esta correto pode-se somar os saldos diarios entre as duas datas

DEFINICOES DA ULTIMA REUNIAO

- Cada campo de(Level_99) Nivel 99 do Cubo pertencera ao grupo de campo correspondente, portanto para cada entidade nova criada deveremos criar novos 
grupos de campos. Sera criado um novo campo na tabela CT0 - no cadastro de Config. Entid. Contabeis (CT0_GRPSXG)
por exemplo: 	Grupo 003 : Level_01 -> Nivel 01 do cubo contera a entidade 01 - Plano de Contas
				Grupo 004 : Level_02 -> Nivel 02 do cubo contera a entidade 02 - Centro de Custo
				Grupo 005 : Level_03 -> Nivel 03 do cubo contera a entidade 03 - Item Contabil
				Grupo 006 : Level_04 -> Nivel 04 do cubo contera a entidade 04 - Classe de Valor
				Grupo ??? : Level_05 -> Nivel 05 do cubo contera a entidade 05 - RUC / NIT (Entidade 05 - tabela  CV0 - Colombia e Peru)
ate				Grupo ??? : Level_09 -> Nivel 09 do cubo contera a entidade 09 - Entidade (CV0)

- Teremos 09 cubos (Moeda e Tipo de Saldo sao fixo em todos os cubos)
	Cubo 01 ==> Plano de Contas
	Cubo 02 ==> Plano de Contas + Centro de Custo
	Cubo 03 ==> Plano de Contas + Centro de Custo + Item Contabil
	Cubo 04 ==> Plano de Contas + Centro de Custo + Item Contabil + Classe de Valor
	Cubo 05 ==> Plano de Contas + Centro de Custo + Item Contabil + Classe de Valor+Entidade 05 (RUC/NIT)
	Cubo 06 ==> Plano de Contas + Centro de Custo + Item Contabil + Classe de Valor+Entidade 05+Entidade 06
	Cubo 07 ==> Plano de Contas + Centro de Custo + Item Contabil + Classe de Valor+Entidade 05+Entidade 06+Entidade 07
	Cubo 08 ==> Plano de Contas + Centro de Custo + Item Contabil + Classe de Valor+Entidade 05+Entidade 06+Entidade 07+Entidade 08
	Cubo 09 ==> Plano de Contas + Centro de Custo + Item Contabil + Classe de Valor+Entidade 05+Entidade 06+Entidade 07+Entidade 08+Entidade 09
	
- Indice das tabelas de saldos sera Nivel 01 ate Nivel 09

- Na rotina de gravacao de saldos os campos de niveis nao utilizados gravaremos espaco em branco

- Na rotina de recuperacao do saldo do cubo os campos de niveis nao utilizados deverao ter a condica entidade == branco para melhor aproveitamento do indice

- Definicao dos cubos a ser utilizado se baseara na tabela CT0 - Conf. Entid. Contabeis


DEFINICOES DA REUNIAO COM ALICE (DBA)

. Procedure para atualiza็ใo do cubo sera dinamica, mas com controle de cria็ใo por assinatura(so criara novamente se mudar a assinatura). 

. Saldos continuam sendo nใo cumulativos

. Semaforo para bloqueio de atualiza็๕es sera feito no registro da tabela CT0-Conf.Entid.Contabeis (duvida->somente para reprocessamento??)

. Converter o pacote de procedures referente a CTB185 da versao 11 para a versao 10 

---> Observacao
. A tabela CV0 campo CV0_CODIGO nao pode estar em nenhum grupo de campos das entidades pois eh comum para entidades 05 ate 09, portanto, cuidado se alterar o tamanho do campo CV0_CODIGO

//------------------------------------------------------------------------------------------//

Campos a ser criado na tabela CT0 - Configura็ใo Entidade Contabil

CT0_CPOCHV C 10 =>Campo Chave 
CT0_CPODSC C 10         Descri็ใo
CT0_CPOSUP C 10         Codigo Entidade Superior
CT0_GRPSXG C 3          Grupo de Campos
CT0_F3ENTI C 5          Consulta Padrao (F3)

Popular os seguintes conteudos para Entidade 01 - Plano de Contas 
CT0_CPOCHV => CT1_CONTA
CT0_CPODSC => CT1_DESC01
CT0_CPOSUP => CT1_CTASUP
CT0_GRPSXG => 003
CT0_F3ENTI => CT1

Popular os seguintes conteudos para Entidade 02 - Centros de Custo
CT0_CPOCHV => CTT_CUSTO
CT0_CPODSC => CTT_DESC01
CT0_CPOSUP => CTT_CCSUP
CT0_GRPSXG => 004
CT0_F3ENTI => CTT

Popular os seguintes conteudos para Entidade 03 - Item Contabil
CT0_CPOCHV => CTD_ITEM
CT0_CPODSC => CTD_DESC01
CT0_CPOSUP => CTD_ITSUP
CT0_GRPSXG => 005
CT0_F3ENTI => CTD

Popular os seguintes conteudos para Entidade 04 - Classe de Valor
CT0_CPOCHV => CTH_CLVL
CT0_CPODSC => CTH_DESC01
CT0_CPOSUP => CTH_CLSUP
CT0_GRPSXG => 006
CT0_F3ENTI => CTH

Popular os seguintes conteudos para Entidade 05 - NIT
CT0_CPOCHV => CV0_CODIGO
CT0_CPODSC => CV0_DESC
CT0_CPOSUP => CV0_ENTSUP
CT0_GRPSXG => 040
CT0_F3ENTI => CV01


---------------------------------------------------------------------------- */

METHOD GetCubeDate_Retrieve_Balance() CLASS CtbManagerial_Cubes

Local aSaldo := {0,0}
Local nX
Local oLstMensal
Local oLstDiario
Local oLstFechto
Local dFechamento := Ctod(Space(8))
/*
Balance_on_Date  --> Saldo na Data

				Code_Cube --> Codigo do Cubo - oLstRec contem o Registro do CT0 referente ao cubo
				                               por exemplo : Cubo 01 - Conta Contabil
				                               				 Cubo 02 - Conta Contabil + Centro de Custo
				Currency --> Moeda
				Type_Of_Balance --> Tipo de Saldo 
				Ctb_Date --> Data
				Keyset_Levels --> Array contendo as chaves por nivel
				                  ex: Nivel 1 - Conta Contabil
				                      Nivel 2 - Centro de Custo
				                      Nivel 3 - Item Contabil
				                      Nivel 4 - Classe de Valor
				                      { "11101001", "CC001", "IT001", "CL001", " ",  }
Regras :

	Se data for ultimo dia do mes:
	- Pegar o saldo de fechamento (CVZ) e a data de fechamento
	- Somar todos os saldos mensais maior que fechamento e menor ou igual a data de acordo as informacoes fornecidas

	Se data NAO for ultimo dia do mes:
	- Somar todos os saldos mensais anteriores a data de acordo as informacoes fornecidas
	- Acrescentar a Soma de todos os saldos diarios ate a data fornecida

Retorno:
	- Valor do saldo na data na forma de array : { Valor Debito, Valor Credito }
	         // se nao existir traz 0 (zero) nas 2 colunas
*/

If  Self:Ctb_Date == LastDay(Self:Ctb_Date) //	Se data for ultimo dia do mes:

	oLstFechto := CtbRetFechtoSld(Self:Code_Cube,Self:Currency,Self:Type_Of_Balance,Self:Ctb_Date,Self:Keyset_Levels)

    If oLstFechto:CountRecords() != 0
	    If oLstFechto:CountRecords() == 1
	 		oLstFechto:SetPosition(1)
			oLstFechto:SetRecord()
	
	    	dFechamento := CVZ->CVZ_DATA
	    	
	    	aSaldo := { CVZ->CVZ_SLDDEB, CVZ->CVZ_SLDCRD}
	    Else
	    	Aviso(STR0001,STR0003,{"Ok"})  //"Atencao"###"Erro no saldo de fechamento para a chave atual do cubo !"
	    EndIf
    EndIf

	If DTOS(Self:Ctb_Date) != DTOS(dFechamento)  //pq se for a mesma data considera o saldo do fechamento
		// Somar todos os saldos mensais menor ou igual a data de acordo as informacoes fornecidas
		oLstMensal := CtbRetMensalSld(Self:Code_Cube,Self:Currency,Self:Type_Of_Balance,Self:Ctb_Date,Self:Keyset_Levels,dFechamento)
		For nX := 1 TO oLstMensal:CountRecords()
			oLstMensal:SetPosition(nX)
			oLstMensal:SetRecord()
		
    	    aSaldo[1] += CVY->CVY_SLDDEB //debito
        	aSaldo[2] += CVY->CVY_SLDCRD //credito
     
		Next
	EndIf
	
Else   //Se data NAO for ultimo dia do mes:

	oLstFechto := CtbRetFechtoSld(Self:Code_Cube,Self:Currency,Self:Type_Of_Balance,Self:Ctb_Date,Self:Keyset_Levels)

    If oLstFechto:CountRecords() != 0
	    If oLstFechto:CountRecords() == 1
	 		oLstFechto:SetPosition(1)
			oLstFechto:SetRecord()
	
	    	dFechamento := CVZ->CVZ_DATA
	    	
	    	aSaldo := { CVZ->CVZ_SLDDEB, CVZ->CVZ_SLDCRD}
	    Else
	    	Aviso(STR0001,STR0003,{"Ok"})  //"Atencao"###"Erro no saldo de fechamento para a chave atual do cubo !"
	    EndIf
    EndIf

	If DTOS(Self:Ctb_Date) != DTOS(dFechamento)  //pq se for a mesma data considera o saldo do fechamento
		// Somar todos os saldos mensais menor ou igual a data de acordo as informacoes fornecidas
		oLstMensal := CtbRetMensalSld(Self:Code_Cube,Self:Currency,Self:Type_Of_Balance,Self:Ctb_Date,Self:Keyset_Levels,dFechamento)
		For nX := 1 TO oLstMensal:CountRecords()
			oLstMensal:SetPosition(nX)
			oLstMensal:SetRecord()
			
	        aSaldo[1] += CVY->CVY_SLDDEB //debito
    	    aSaldo[2] += CVY->CVY_SLDCRD //credito
     
		Next

		// Acrescentar a Soma de todos os saldos diarios do mes ate a data fornecida
		oLstDiario := CtbRetSldDiario(Self:Code_Cube,Self:Currency,Self:Type_Of_Balance,Self:Ctb_Date,Self:Keyset_Levels,dFechamento)
		For nX := 1 TO oLstDiario:CountRecords()
			oLstDiario:SetPosition(nX)
			oLstDiario:SetRecord()
		
	        aSaldo[1] += CVX->CVX_SLDDEB //debito
	        aSaldo[2] += CVX->CVX_SLDCRD //credito
     
		Next
	EndIf

EndIf

RETURN aSaldo

METHOD GetCubePeriod_Retrieve_Balances(Ctb_Date1,Ctb_Date2,lMovement) CLASS CtbManagerial_Cubes

Local aSaldo := {0,0}
Local nX

Local oLstDiario
Local oLstFechto
Local dFechamento := Ctod(Space(8))
Local dDatAnt

/*
				Ctb_Date1 --> Data Inicial
				Ctb_Date1 --> Data Final
				lMovement --> Se retorna saldo do periodo ou movimento do periodo
								se for movimento somente enxerga a tabela CVX - Movimentos diarios
								se for saldo tem que ir no fechamento (CVZ) recuperar saldo inicial 
													 ir no movimento mensal (CVY) recuperar saldo dos meses entre date1 e date2
													 ir no movimento diario (CVX) recuperar saldos diarios
*/
If lMovement
	oLstFechto := CtbRetFechtoSld(Self:Code_Cube,Currency,Type_Of_Balance,Ctb_Date1,Keyset_Levels)

    If oLstFechto:CountRecords() != 0
	    If oLstFechto:CountRecords() == 1
	 		oLstFechto:SetPosition(1)
			oLstFechto:SetRecord()
	        //somente pegar a data de fechamento 
	    	dFechamento := CVZ->CVZ_DATA
	    	
	    Else
	    	Aviso(STR0001,STR0003,{"Ok"})  //"Atencao"
	    EndIf
    EndIf

	If DTOS(Ctb_Date2) > DTOS(dFechamento)  

		// Acrescentar a Soma de todos os saldos diarios do mes ate a data fornecida
		oLstDiario := CtbRetMovDiario(Self:Code_Cube,Self:Currency,Self:Type_Of_Balance,Ctb_Date1,Ctb_Date2,Self:Keyset_Levels,dFechamento)
		For nX := 1 TO oLstDiario:CountRecords()
			oLstDiario:SetPosition(nX)
			oLstDiario:SetRecord()
		
	        aSaldo[1] += CVX->CVX_SLDDEB //debito
    	    aSaldo[2] += CVX->CVX_SLDCRD //credito
     
		Next
	
	EndIf

Else

	dDatAnt := Self:Get_Ctb_Date()
	Self:Set_Ctb_Date(Ctb_Date1)

	aSaldo1 := Self:GetCubeDate_Retrieve_Balance()

	Self:Set_Ctb_Date(Ctb_Date2)

	aSaldo2 := Self:GetCubeDate_Retrieve_Balance()

	Self:Set_Ctb_Date(dDatAnt)

	aSaldo[1] += aSaldo2[1]-aSaldo1[1]
	aSaldo[2] += aSaldo2[2]-aSaldo1[2]

EndIf

RETURN aSaldo

METHOD Set_InitSemaforo()  CLASS CtbManagerial_Cubes
Local nX
Local cChave := ""
cChave += xFilial("CVY")
cChave += Self:Code_Cube
cChave += Self:Currency
cChave += Self:Type_of_Balance
cChave += DTOS(LastDay(Self:Ctb_Date))

For nX := 1 TO Len(Self:Keyset_Levels)
	cChave += Self:Keyset_Levels[nX]
Next

// Retira os espacos para nao entrar em loop infinito no While abaixo!!!
cChave := AllTrim( cChave )

//inicia o semaforo
While !LockByName(cChave,.T.,.T.,.T.)
	Sleep(1)
EndDo

Return

METHOD Set_FinishSemaforo()  CLASS CtbManagerial_Cubes
Local nX
Local cChave := ""

cChave += xFilial("CVY")
cChave += Self:Code_Cube
cChave += Self:Currency
cChave += Self:Type_of_Balance
cChave += DTOS(LastDay(Self:Ctb_Date))


For nX := 1 TO Len(Self:Keyset_Levels)
	cChave += Self:Keyset_Levels[nX]
Next

// Retira os espacos para nao entrar em loop infinito no While abaixo!!!
cChave := AllTrim( cChave )

UnLockByName(cChave,.T.,.T.,.T.)

Return		

METHOD Set_ExpKeyBuild(cType_of_Movement) CLASS CtbManagerial_Cubes
/*
				Type_of_Movement --> Tipo lancamento (D-ebito ou C-redito ou P-artida Dobrada)
*/
Local nRecCT0
Local oLstRec := Self:Get_DataGeneral()

If oLstRec:CountRecords() == 1
	oLstRec:SetPosition(1)
	oLstRec:SetRecord()
	
	nRecCT0 := CT0->( Recno() )
	
	dbSelectArea("CT0")
	dbSetOrder(1)
	CT0->( dbSeek(xFilial("CT0")) )
	
	While CT0->( ! Eof() .And. CT0_FILIAL = xFilial("CT0") )
	
		If cType_of_Movement == "P"
			aAdd(Self:aDebExpKeyset_Levels, CtbCposCrDb(CT0->CT0_ALIAS/*cAlias*/, "D"/*cOperacao*/, CT0->CT0_ID/*cIdEntid*/) )
			aAdd(Self:aCrdExpKeyset_Levels, CtbCposCrDb(CT0->CT0_ALIAS/*cAlias*/, "C"/*cOperacao*/, CT0->CT0_ID/*cIdEntid*/) )
		
		ElseIf cType_of_Movement == "D"
			aAdd(Self:aDebExpKeyset_Levels, CtbCposCrDb(CT0->CT0_ALIAS/*cAlias*/, cType_of_Movement/*cOperacao*/, CT0->CT0_ID/*cIdEntid*/) )
		
		ElseIf cType_of_Movement == "C"
			aAdd(Self:aCrdExpKeyset_Levels, CtbCposCrDb(CT0->CT0_ALIAS/*cAlias*/, cType_of_Movement/*cOperacao*/, CT0->CT0_ID/*cIdEntid*/) )
		
	    EndIf
	    
		If CT0->( Recno() ) == nRecCT0
			Exit
		EndIf
		
		CT0->( dbSkip() )
    
    EndDo

EndIf

Return 


METHOD Set_BuildKey()  CLASS CtbManagerial_Cubes
Local nX

If Self:Type_of_Movement == "D"  //debito
	Self:aDebKeySet_Levels := Array(Len(Self:aDebExpKeyset_Levels))
	For nX := 1 TO Len(Self:aDebExpKeyset_Levels)
		Self:aDebKeySet_Levels[nX] := (Self:Alias_Movement)->(&(Self:aDebExpKeyset_Levels[nX]))
	Next
	Self:Set_Keyset_Levels(Self:aDebKeySet_Levels) //array conteudo ja macro executado expressao a debito
EndIF

If Self:Type_of_Movement == "C"  //credito
	Self:aCrdKeySet_Levels := Array(Len(Self:aCrdExpKeyset_Levels))
	For nX := 1 TO Len(Self:aCrdExpKeyset_Levels)
		Self:aCrdKeySet_Levels[nX] := (Self:Alias_Movement)->(&(Self:aCrdExpKeyset_Levels[nX]))
	Next
	Self:Set_Keyset_Levels(Self:aCrdKeySet_Levels) //array bconteudo ja macro executado expressao a debito
EndIF

Return

METHOD Set_Write_Balance(cType_of_Movement,cOperation,nValue) CLASS CtbManagerial_Cubes
/*
				cType_of_Movement --> Tipo lancamento (D-ebito ou C-redito)
				cOperation --> Opera็ใo ( Somar ou Diminuir )
*/

Local oLstDiario
Local oLstMensal
Local lRedStorn	:= cPaisLoc == "RUS" .And. SuperGetMV("MV_REDSTOR",.F.,.F.) // CAZARINI - 20/06/2017 - Parameter to activate Red Storn

Default cOperation := "+" // "+" = Somar "-" = Subtrair

//inicializa semaforo
Self:Set_InitSemaforo()

//caso nao exista saldo movimento diario a funcao cria, isto eh, sempre retorna lista com o registro 
oLstDiario := CtbSldDiario(Self:Code_Cube,Self:Currency,Self:Type_Of_Balance,Self:Ctb_Date,Self:Keyset_Levels)

//caso nao exista saldo mensal a funcao cria, isto eh, sempre retorna lista com o registro 
oLstMensal := CtbSldMensal(Self:Code_Cube,Self:Currency,Self:Type_Of_Balance,Self:Ctb_Date,Self:Keyset_Levels)

If oLstDiario:CountRecords() != 1 .OR. oLstMensal:CountRecords() != 1
	Aviso(STR0001,STR0004,{"Ok"})  //"Atencao"##"Nao atualizado saldo para a chave atual do cubo !"
	Return
EndIf

//Operation 1 = somar 2= diminuir
If !lRedStorn
	nValue := If(cOperation=="+", nValue, nValue*-1)
EndIf

//atualiza saldo diario
oLstDiario:SetPosition(1)
oLstDiario:SetRecord()

CtbCVXAtlSld( cType_of_Movement, nValue )

//atualiza saldo mensal
oLstMensal:SetPosition(1)
oLstMensal:SetRecord()

CtbCVYAtlSld( cType_of_Movement, nValue )

//finaliza semaforo
Self:Set_FinishSemaforo()

Return



/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณCtbCposCrDb     บAutor  ณMicrosiga           บ Data ณ  30/03/10   บฑฑ
ฑฑฬออออออออออุออออออออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณRetorna o nome do campo da tabela de movimentos (CT2) referente   บฑฑ
ฑฑบ          ณao tipo de movimento informado para o alias selecionado           บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                               บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Function CtbCposCrDb(cAlias, cTpMovimento, cIdEntid)
Local cCpo := ""
Default cIdEntid := ""

Do Case
	Case cAlias == "CT1"  //Plano de Contas
		If cTpMovimento == "D" //Debito
			cCpo := "CT2_DEBITO"
		ElseIf cTpMovimento == "C" //Credito
			cCpo := "CT2_CREDIT"
		EndIf
	Case cAlias == "CTT"  //Centro de Custo
		If cTpMovimento == "D" //Debito
			cCpo := "CT2_CCD"
		ElseIf cTpMovimento == "C" //Credito
			cCpo := "CT2_CCC"
		EndIf
			
	Case cAlias == "CTD"  //Item Contabil
		If cTpMovimento == "D" //Debito
			cCpo := "CT2_ITEMD"
		ElseIf cTpMovimento == "C" //Credito
			cCpo := "CT2_ITEMC"
		EndIf
	Case cAlias == "CTH"
		If cTpMovimento == "D" //Debito
			cCpo := "CT2_CLVLDB"
		ElseIf cTpMovimento == "C" //Credito
			cCpo := "CT2_CLVLCR"
		EndIf
	OTHERWISE
		If !Empty(cIdEntid)	
			If cTpMovimento == "D" //Debito
				cCpo := "CT2_EC"+cIdEntid+"DB"
			ElseIf cTpMovimento == "C" //Credito
				cCpo := "CT2_EC"+cIdEntid+"CR"
			EndIf
		EndIf
EndCase

Return(cCpo)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณCtbCubeStruct   บAutor  ณMicrosiga           บ Data ณ  30/03/10   บฑฑ
ฑฑฬออออออออออุออออออออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณRetorna lista de registros com um unico registro da CTO correspon-บฑฑ
ฑฑบ          ณdente a entidade selecionada                                      บฑฑ
ฑฑบ          ณpor exemplo cubo 02 - Centro de Custo                             บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                               บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Function Ctb_SetCube(cCodeCube)
Local oListRec
Local cQuery := ""
oListRec := Adm_List_Records():New()
oListRec:SetAlias("CT0")  //alias
oListRec:SetOrder(1)		//ordem do indice	

cQuery += " SELECT R_E_C_N_O_ NUM_RECNO FROM "+RetSqlName("CT0")
cQuery += " WHERE "
cQuery += " CT0_FILIAL = '"+xFilial("CT0")+"' "
cQuery += " AND CT0_ID = '"+cCodeCube+"' "
cQuery += " AND D_E_L_E_T_ = ' ' " //OBRIGATORIO PARA NAO MOSTRAR OS DELETADOS
cQuery += " ORDER BY CT0_ID " 

oListRec:SetQuery_Expression( cQuery )
oListRec:Fill_Records() //preenche os registros

Return oListRec


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณCtbCubeStruct   บAutor  ณMicrosiga           บ Data ณ  30/03/10   บฑฑ
ฑฑฬออออออออออุออออออออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณRetorna lista de registros correspondente a estrutura do cubo.    บฑฑ
ฑฑบ          ณAdotaremos o seguinte padrao:                                     บฑฑ
ฑฑบ          ณCT0->CTO_ID sera o codigo do cubo                                 บฑฑ
ฑฑบ          ณpor exemplo cubo 02 - Centro de Custo                             บฑฑ
ฑฑบ          ณa estrutura deste cubo e composta pelos registros da CTO refe-    บฑฑ
ฑฑบ          ณrente a conta contabil (entidade 01) e ao centro de custo         บฑฑ
ฑฑบ          ณ                                                                  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                               บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Function CtbCubeStruct(cCodeCube)
Local oListRec
Local cQuery := ""
oListRec := Adm_List_Records():New()
oListRec:SetAlias("CT0")  //alias
oListRec:SetOrder(1)		//ordem do indice	

cQuery += " SELECT R_E_C_N_O_ NUM_RECNO FROM "+RetSqlName("CT0")
cQuery += " WHERE "
cQuery += " CT0_FILIAL = '"+xFilial("CT0")+"' "
cQuery += " AND CT0_ID <= '"+cCodeCube+"' "
cQuery += " AND D_E_L_E_T_ = ' ' " //OBRIGATORIO PARA NAO MOSTRAR OS DELETADOS
cQuery += " ORDER BY CT0_ID " 

oListRec:SetQuery_Expression( cQuery )
oListRec:Fill_Records() //preenche os registros

Return oListRec

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณCtbSldDiario    บAutor  ณMicrosiga           บ Data ณ  30/03/10   บฑฑ
ฑฑฬออออออออออุออออออออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณRetorna lista de registros saldos DIARIO de uma determinada data. บฑฑ
ฑฑบ          ณSe nao encontrado esta data cria o registro n a tabela CVX        บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                               บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Static Function CtbSldDiario(cCodeCube,cMoeda,cTipoSaldo,dLancto,aChave)
Local nX
Local oLstRec
Local nCpoPos
Local aParQry2 := {}

oLstRec := Adm_List_Records():New()
oLstRec:SetAlias("CVX")  //alias
oLstRec:SetOrder(1)		 //ordem do indice
If Empty( _aQryCbDia[Val(cCodeCube)] )
	_cQueryDia := NIL
	_lChngQryD := .T.
	If _cQueryDia == NIL
		_cQueryDia := " SELECT R_E_C_N_O_ NUM_RECNO FROM "+RetSqlName("CVX")
		_cQueryDia += " WHERE "
		_cQueryDia += " CVX_FILIAL = ? "
		_cQueryDia += " AND CVX_CONFIG = ? "
		_cQueryDia += " AND CVX_MOEDA = ? "
		_cQueryDia += " AND CVX_TPSALD = ? "
		_cQueryDia += " AND CVX_DATA = ? "
		For nX := 1 TO Len(aChave)
			If CVX->(FieldPos("CVX_NIV"+StrZero(nX,2))) >  0
				_cQueryDia += " AND CVX_NIV"+StrZero(nX,2)+" = ? "
			EndIf
		Next
		_cQueryDia += " AND D_E_L_E_T_ = ' ' " //OBRIGATORIO PARA NAO MOSTRAR OS DELETADOS
	EndIf

	If _lChngQryD
		_cQueryDia := ChangeQuery(_cQueryDia)
		_lChngQryD := .F.
	EndIf
	_aQryCbDia[Val(cCodeCube)] := _cQueryDia
Else
	_cQueryDia := _aQryCbDia[Val(cCodeCube)]
EndIf

oLstRec:SetQuery_Expression( _cQueryDia )
oLstRec:SetTcGenQry2(.T.)
aParQry2 := {}
aAdd(aParQry2, xFilial("CVX"))
aAdd(aParQry2, cCodeCube)
aAdd(aParQry2, cMoeda)
aAdd(aParQry2, cTipoSaldo)
aAdd(aParQry2, DTOS(dLancto))
For nX := 1 TO Len(aChave)
	If CVX->(FieldPos("CVX_NIV"+StrZero(nX,2))) >  0
		aAdd(aParQry2, aChave[nX])
	EndIf
Next
oLstRec:SetParQry2(aParQry2)

oLstRec:Fill_Records()   //preenche os registros

If oLstRec:CountRecords()==0  //se nao encontrar o registro entao cria 
	dbSelectArea("CVX")
	RecLock("CVX",.T.)
	CVX->CVX_FILIAL := xFilial("CVX")
	CVX->CVX_CONFIG := cCodeCube
	CVX->CVX_MOEDA := cMoeda
	CVX->CVX_TPSALD := cTipoSaldo	
	CVX->CVX_DATA	:= dLancto
	For nX := 1 TO Len(aChave)
		nCpoPos := FieldPos("CVX_NIV"+StrZero(nX,2))
		If nCpoPos > 0
			FieldPut(nCpoPos, 	aChave[nX])
		EndIf
	Next
	MsUnLock()
	CVX->( dbCommit() )
	CVX->( oLstRec:AddRecord(&(IndexKey()), Recno()) )

EndIf

Return(oLstRec)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณCtbSldMensal    บAutor  ณMicrosiga           บ Data ณ  30/03/10   บฑฑ
ฑฑฬออออออออออุออออออออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณRetorna lista de registros saldos Mensais de uma determinada data.บฑฑ
ฑฑบ          ณSe nao encontrado esta data cria o registro n a tabela CVY        บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                               บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Static Function CtbSldMensal(cCodeCube,cMoeda,cTipoSaldo,dLancto,aChave)
Local nX
Local oLstRec
Local nCpoPos
Local cQuery := ""
Local aParQry2 := {}

oLstRec := Adm_List_Records():New()
oLstRec:SetAlias("CVY")  //alias
oLstRec:SetOrder(1)		 //ordem do indice	
If Empty( _aQryCbMes[Val(cCodeCube)] )
	_cQueryMes := NIL
	_lChngQryM := .T.

	If _cQueryMes == NIL
		_cQueryMes := " SELECT R_E_C_N_O_ NUM_RECNO FROM "+RetSqlName("CVY")
		_cQueryMes += " WHERE "
		_cQueryMes += " CVY_FILIAL = ? "
		_cQueryMes += " AND CVY_CONFIG = ? "
		_cQueryMes += " AND CVY_MOEDA = ? "
		_cQueryMes += " AND CVY_TPSALD = ? "
		_cQueryMes += " AND CVY_DATA =  ? "
		For nX := 1 TO Len(aChave)
			If CVY->(FieldPos("CVY_NIV"+StrZero(nX,2))) > 0
				_cQueryMes += " AND CVY_NIV"+StrZero(nX,2)+" = ? "
			EndIf
		Next
		_cQueryMes += " AND D_E_L_E_T_ = ' ' " //OBRIGATORIO PARA NAO MOSTRAR OS DELETADOS
	EndIf

	If _lChngQryM
		_cQueryMes := ChangeQuery(_cQueryMes)
		_lChngQryM := .F.
	EndIf
	_aQryCbMes[Val(cCodeCube)] := _cQueryMes
Else
	_cQueryMes := _aQryCbMes[Val(cCodeCube)]
EndIf

oLstRec:SetQuery_Expression( _cQueryMes )
oLstRec:SetTcGenQry2(.T.)
aParQry2 := {}
aAdd(aParQry2, xFilial("CVY"))
aAdd(aParQry2, cCodeCube)
aAdd(aParQry2, cMoeda)
aAdd(aParQry2, cTipoSaldo)
aAdd(aParQry2, DTOS(LastDay(dLancto)))
For nX := 1 TO Len(aChave)
	If CVY->(FieldPos("CVY_NIV"+StrZero(nX,2))) > 0
		aAdd(aParQry2, aChave[nX])"
	EndIf
Next

oLstRec:SetParQry2(aParQry2)

oLstRec:Fill_Records()   //preenche os registros

If oLstRec:CountRecords()==0  //se nao encontrar o registro entao cria 
	dbSelectArea("CVY")
	RecLock("CVY",.T.)
	CVY->CVY_FILIAL := xFilial("CVY")
	CVY->CVY_CONFIG := cCodeCube
	CVY->CVY_MOEDA := cMoeda
	CVY->CVY_TPSALD := cTipoSaldo	
	CVY->CVY_DATA	:= LastDay(dLancto)
	For nX := 1 TO Len(aChave)
		nCpoPos := FieldPos("CVY_NIV"+StrZero(nX,2))
		If nCpoPos > 0
			FieldPut(nCpoPos, 	aChave[nX])
		EndIf
	Next
	MsUnLock()
	CVY->( dbCommit() )
	CVY->( oLstRec:AddRecord(&(IndexKey()), Recno()) )

EndIf

Return(oLstRec)



//-----------------------------------------------------------------------------------------
/*/{Protheus.doc}CtbCbReset()
Retorna o valor original das variaveis static usada nas funcoes
-CtbSldDiario
-CtbSldMensal
@author Totvs
@since  26/11/2021
@version 12/*/
//-----------------------------------------------------------------------------------------
Function CtbCbReset()

_lChngQryD   := .T.
_cQueryDia   := NIL
_aQryCbDia   := {"","","","","","","","",""}
_lChngQryM   := .T.
_cQueryMes   := NIL
_aQryCbMes   := {"","","","","","","","",""}
_cThreadId := 0
_cFunExec := ""

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณCtbRetMensalSld บAutor  ณMicrosiga           บ Data ณ  30/03/10   บฑฑ
ฑฑฬออออออออออุออออออออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณRetorna lista de registros saldos de fechamento igual ou imediata-บฑฑ
ฑฑบ          ณmente anterior a data informada (dDtSaldo)                        บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                               บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Static Function CtbRetFechtoSld(cCodCubo,cMoeda,cTpSaldo,dDtSaldo,aChave)
Local nX
Local oLstRec
Local cQuery := ""

oLstRec := Adm_List_Records():New()
oLstRec:SetAlias("CVZ")  //alias
oLstRec:SetOrder(1)		 //ordem do indice	
cQuery += " SELECT R_E_C_N_O_ NUM_RECNO FROM "+RetSqlName("CVZ")
cQuery += " WHERE "
cQuery += " CVZ_FILIAL = '"+xFilial("CVZ")+"' "
cQuery += " AND CVZ_CONFIG = '"+cCodCubo+"' "
cQuery += " AND CVZ_MOEDA = '"+cMoeda+"' "
cQuery += " AND CVZ_TPSALD = '"+cTpSaldo+"' "
cQuery += " AND CVZ_DATA <= '"+DTOS(dDtSaldo)+"' " // a data do saldo desejado
For nX := 1 TO Len(aChave)
	If CVZ->(FieldPos("CVZ_NIV"+StrZero(nX,2))) > 0
		cQuery += " AND CVZ_NIV"+StrZero(nX,2)+" = '"+aChave[nX]+"' "
	EndIf	
Next
cQuery += " AND D_E_L_E_T_ = ' ' " //OBRIGATORIO PARA NAO MOSTRAR OS DELETADOS

oLstRec:SetQuery_Expression( cQuery )
oLstRec:Fill_Records()   //preenche os registros

Return(oLstRec)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณCtbRetMensalSld บAutor  ณMicrosiga           บ Data ณ  30/03/10   บฑฑ
ฑฑฬออออออออออุออออออออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณRetorna lista de registros saldos diarios do primeiro dia ou do   บฑฑ
ฑฑบ          ณdia do fechamento ate a data informada                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                               บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Static Function CtbRetSldDiario(cCodCubo,cMoeda,cTpSaldo,dDtSaldo,aChave,dFechamento)
Local nX
Local oLstRec
Local cQuery := ""

DEFAULT dFechamento := Ctod(Space(8))

oLstRec := Adm_List_Records():New()
oLstRec:SetAlias("CVX")  //alias
oLstRec:SetOrder(1)		 //ordem do indice	
cQuery += " SELECT R_E_C_N_O_ NUM_RECNO FROM "+RetSqlName("CVX")
cQuery += " WHERE "
cQuery += " CVX_FILIAL = '"+xFilial("CVX")+"' "
cQuery += " AND CVX_CONFIG = '"+cCodCubo+"' "
cQuery += " AND CVX_MOEDA = '"+cMoeda+"' "
cQuery += " AND CVX_TPSALD = '"+cTpSaldo+"' "
If ! Empty(dFechamento)
	cQuery += " AND CVX_DATA > '"+DTOS(dFechamento)+"' "
EndIf
cQuery += " AND CVX_DATA >= '"+Subs(DTOS(dDtSaldo),1,6)+"01' "  //do primeiro dia do mes ate (qdo nao tem fechamento no mes)
cQuery += " AND CVX_DATA <= '"+DTOS(dDtSaldo)+"' " // ATE a data do saldo desejado
For nX := 1 TO Len(aChave)
	If CVX->(FieldPos("CVX_NIV"+StrZero(nX,2))) > 0
		cQuery += " AND CVX_NIV"+StrZero(nX,2)+" = '"+aChave[nX]+"' "
	EndIf	
Next
cQuery += " AND D_E_L_E_T_ = ' ' " //OBRIGATORIO PARA NAO MOSTRAR OS DELETADOS

oLstRec:SetQuery_Expression( cQuery )
oLstRec:Fill_Records()   //preenche os registros

Return(oLstRec)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณCtbRetMensalSld บAutor  ณMicrosiga           บ Data ณ  30/03/10   บฑฑ
ฑฑฬออออออออออุออออออออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณRetorna lista de registros saldos mensais em uma determinada data บฑฑ
ฑฑบ          ณ                                                                  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                               บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function CtbRetMensalSld(cCodCubo,cMoeda,cTpSaldo,dLancto,aChave,dFechamento)
Local nX
Local oLstRec
Local cQuery := ""

DEFAULT dFechamento := Ctod(Space(8))

oLstRec := Adm_List_Records():New()
oLstRec:SetAlias("CVY")  //alias
oLstRec:SetOrder(1)		 //ordem do indice	
cQuery += " SELECT R_E_C_N_O_ NUM_RECNO FROM "+RetSqlName("CVY")
cQuery += " WHERE "
cQuery += " CVY_FILIAL = '"+xFilial("CVY")+"' "
cQuery += " AND CVY_CONFIG = '"+cCodCubo+"' "
cQuery += " AND CVY_MOEDA = '"+cMoeda+"' "
cQuery += " AND CVY_TPSALD = '"+cTpSaldo+"' "
If ! Empty(dFechamento)
	cQuery += " AND CVY_DATA >= '"+DTOS(dFechamento)+"' "
EndIf
cQuery += " AND CVY_DATA <= '"+DTOS(dLancto)+"' "
For nX := 1 TO Len(aChave)
	If CVY->(FieldPos("CVY_NIV"+StrZero(nX,2))) > 0
		cQuery += " AND CVY_NIV"+StrZero(nX,2)+" = '"+aChave[nX]+"' "
	EndIf
Next
cQuery += " AND D_E_L_E_T_ = ' ' " //OBRIGATORIO PARA NAO MOSTRAR OS DELETADOS

oLstRec:SetQuery_Expression( cQuery )
oLstRec:Fill_Records()   //preenche os registros

Return(oLstRec)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณCtbRetMovDiario บAutor  ณMicrosiga           บ Data ณ  30/03/10   บฑฑ
ฑฑฬออออออออออุออออออออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณRetorna lista de registros saldos diarios em um determinado       บฑฑ
ฑฑบ          ณperiodo                                                           บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                               บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Static Function CtbRetMovDiario(cCodCubo,cMoeda,cTpSaldo,dDtSaldo1,dDtSaldo2,aChave,dFechamento)
Local nX
Local oLstRec
Local cQuery := ""

DEFAULT dFechamento := CtoD(Space(8))

oLstRec := Adm_List_Records():New()
oLstRec:SetAlias("CVX")  //alias
oLstRec:SetOrder(1)		 //ordem do indice	
cQuery += " SELECT R_E_C_N_O_ NUM_RECNO FROM "+RetSqlName("CVX")
cQuery += " WHERE "
cQuery += " CVX_FILIAL = '"+xFilial("CVX")+"' "
cQuery += " AND CVX_CONFIG = '"+cCodCubo+"' "
cQuery += " AND CVX_MOEDA = '"+cMoeda+"' "
cQuery += " AND CVX_TPSALD = '"+cTpSaldo+"' "
If !Empty(dFechamento)
	cQuery += " AND CVX_DATA > '"+DTOS(dFechamento)+"' "
EndIf
cQuery += " AND CVX_DATA >= '"+DTOS(dDtSaldo1)+"' "  
cQuery += " AND CVX_DATA <= '"+DTOS(dDtSaldo2)+"' " 
For nX := 1 TO Len(aChave)
	If CVX->(FieldPos("CVX_NIV"+StrZero(nX,2))) > 0
		cQuery += " AND CVX_NIV"+StrZero(nX,2)+" = '"+aChave[nX]+"' "
	EndIf
Next
cQuery += " AND D_E_L_E_T_ = ' ' " //OBRIGATORIO PARA NAO MOSTRAR OS DELETADOS

oLstRec:SetQuery_Expression( cQuery )
oLstRec:Fill_Records()   //preenche os registros

Return(oLstRec)


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณCtbCVXAtlSld บAutor  ณMicrosiga           บ Data ณ  30/03/10   บฑฑ
ฑฑฬออออออออออุอออออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณAtualiza os valores saldo a debito e credito (DIARIO)          บฑฑ
ฑฑบ          ณ                                                               บฑฑ
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                            บฑฑ
ฑฑศออออออออออฯอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Static Function CtbCVXAtlSld( Type_of_Movement, nValor )
//deve estar posicionado no registro a ser atualizado

//*************************
// Altera saldo da chave  *
//*************************
RecLock("CVX",.F.)
If Type_of_Movement == "C"
	CVX->CVX_SLDCRD += nValor
ElseIf Type_of_Movement == "D"
	CVX->CVX_SLDDEB += nValor
EndIf
MsUnlock()
CVX->( dbCommit() )

Return


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณCtbCVYAtlSld บAutor  ณMicrosiga           บ Data ณ  30/03/10   บฑฑ
ฑฑฬออออออออออุอออออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณAtualiza os valores saldo a debito e credito (MENSAL)          บฑฑ
ฑฑบ          ณ                                                               บฑฑ
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                            บฑฑ
ฑฑศออออออออออฯอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Static Function CtbCVYAtlSld( Type_of_Movement, nValor )
//deve estar posicionado no registro a ser atualizado

//*************************
// Altera saldo da chave  *
//*************************
RecLock("CVY",.F.)
If Type_of_Movement == "C"
	CVY->CVY_SLDCRD += nValor
ElseIf Type_of_Movement == "D"
	CVY->CVY_SLDDEB += nValor
EndIf
MsUnlock()
CVY->( dbCommit() )

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณCtbLstReg    บAutor  ณMicrosiga           บ Data ณ  30/03/10   บฑฑ
ฑฑฬออออออออออุอออออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณRetorna objeto lista de registros com apenas o registro atual  บฑฑ
ฑฑบ          ณposicionado                                                    บฑฑ
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                            บฑฑ
ฑฑศออออออออออฯอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function CtbLstReg()
Local oLstRec
oLstRec := Adm_List_Records():New()
oLstRec:SetCurrentRecord()
Return(oLstRec)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออออออหอออออออัอออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณCtb_Load_CubesบAutor  ณMicrosiga          บ Data ณ  30/03/10   บฑฑ
ฑฑฬออออออออออุออออออออออออออสอออออออฯอออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณRetorna objeto conjunto de cubos                               บฑฑ
ฑฑบ          ณ                                                               บฑฑ
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                            บฑฑ
ฑฑศออออออออออฯอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Function Ctb_Load_Cubes()
Local oConjCubos
Local oCubo, oLstCT0, oLstReg, oLstStruct
Local nX

oConjCubos := 	CtbCubes_Set():New()
				
//Loop no arquivo CT0
oLstCT0 := Adm_List_Records():New()
oLstCT0:SetAlias("CT0")  //alias
oLstCT0:SetOrder(1)	  //ordem do indice	
oLstCT0:Fill_Records()   //preenche os registros

For nX := 1 TO oLstCT0:CountRecords()
    //posiciona no registro
	oLstCT0:SetPosition(nX)
	oLstCT0:SetRecord()
	If CT0->CT0_CONTR == "1"   //somente para os que controlam saldo
	    //cria uma lista com registro corrente
		oLstReg := CtbLstReg()
		//cria objeto cubo
		oCubo := CtbManagerial_Cubes():New()  
		oCubo:Set_DataGeneral(oLstReg)
		oLstStruct := CtbCubeStruct(oCubo:GetCode_Cube())
		oCubo:Set_Struct(oLstStruct)
		oCubo:Set_ExpKeyBuild("P")  //monta as expressoes em advpl para os valores a debito e credito
	
		//adiciona no conjunto de cubos 
		oConjCubos:SetAddCube_Set(oCubo)
	EndIf	
				
Next //nX

Return(oConjCubos)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณCtb_Run_CubesบAutor  ณMicrosiga           บ Data ณ  30/03/10   บฑฑ
ฑฑฬออออออออออุอออออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณGrava os saldos diario e mensal do cubo para o conjunto de     บฑฑ
ฑฑบ          ณcubos informado                                                บฑฑ
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                            บฑฑ
ฑฑศออออออออออฯอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function Ctb_Run_Cubes(oConjCubos,cAliasMov,cOperacao)
//para atualizacao de todos os cubos de acordo com movimento 
Local oCubo
Local nX
Local cTpSldAux := ""

Default cAliasMov := "CT2"
Default cOperacao := "+"

If ThreadID() <> _cThreadId .Or. FunName() <> _cFunExec
	CtbCbReset()
	_cThreadId := ThreadID()
	_cFunExec := FunName()
EndIf

cTpSldAux := (cAliasMov)->CT2_TPSALD 

If cTpSldAux <> '9'    //9=PRE-LANCTO
	For nX := 1 TO oConjCubos:CountCube()
		
		oConjCubos:SetPosition(nX)
		oCubo := oConjCubos:GetCube()
		
		oCubo:Set_Alias_Movement( cAliasMov )   //seta alias de movimento
		oCubo:Set_Currency( (cAliasMov)->CT2_MOEDLC )  //seta moeda
		oCubo:Set_Type_Of_Balance( (cAliasMov)->CT2_TPSALD ) //seta tipo de saldo
		oCubo:Set_Ctb_Date( (cAliasMov)->CT2_DATA )  //seta data da contabilizacao
		
		If (cAliasMov)->CT2_DC == "1"   //debito
			oCubo:Set_Movement_Type("D")
			oCubo:Set_BuildKey()  //macro executa as expressoes de acordo a estrutura do cubo
			oCubo:Set_Write_Balance("D",cOperacao,(cAliasMov)->CT2_VALOR)

		ElseIf  (cAliasMov)->CT2_DC == "2"  //credito
			oCubo:Set_Movement_Type("C")
			oCubo:Set_BuildKey()  //macro executa as expressoes de acordo a estrutura do cubo
			oCubo:Set_Write_Balance("C",cOperacao,(cAliasMov)->CT2_VALOR)

		ElseIf  (cAliasMov)->CT2_DC == "3"  //partida dobrada
			oCubo:Set_Movement_Type("D")
			oCubo:Set_BuildKey()  //macro executa as expressoes de acordo a estrutura do cubo
			oCubo:Set_Write_Balance("D",cOperacao,(cAliasMov)->CT2_VALOR)
			
			oCubo:Set_Movement_Type("C")
			oCubo:Set_BuildKey()  //macro executa as expressoes de acordo a estrutura do cubo
			oCubo:Set_Write_Balance("C",cOperacao,(cAliasMov)->CT2_VALOR)

		EndIf
		
	Next 	
EndIf

Return 	


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณCtb_RprCub   บAutor  ณMicrosiga           บ Data ณ  30/03/10   บฑฑ
ฑฑฬออออออออออุอออออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณGrava os saldos diario e mensal do cubo para o conjunto de     บฑฑ
ฑฑบ          ณcubos informado no reprocessamento de saldos                   บฑฑ
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                            บฑฑ
ฑฑศออออออออออฯอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function Ctb_RprCub(oConjCubos, aSM0, dDataIni, dDataFim, cTpSaldo, cFilialDe, cFilialAte, lAllMoedas, cQualMoed, oObj)
Local aArea			:= GetArea()
Local cQuery		:= ""
Local cAux			:= ""
Local lExclusivo	:= If(FindFunction("ADMTabExc"), ADMTabExc("CT2"), !Empty(xFilial("CT2"))) //Analisa se a tabela esta exclusiva
Local nX			:= 0

If ValType(oObj) == "O"
	oObj:IncRegua1(STR0008) //"Zerando arquivos de saldos diario do cubo..."
EndIf

//Apagar todos os saldos diarios (CVX) entre data inicial e final 
If __lFKInUse                 
	cQuery  += " UPDATE " + RetSqlName('CVX')
	cQuery  += " SET D_E_L_E_T_ = '*', R_E_C_D_E_L_ = R_E_C_N_O_ "
Else
	cQuery += " DELETE FROM " +RetSqlName("CVX")
EndIf
cQuery += " WHERE "
If !Empty(cFilialDe) .And. cFilialDe == cFilialAte
	cQuery += " CVX_FILIAL = '"+ xFilial("CVX",cFilialDe) +"'"
Else
	cQuery += " CVX_FILIAL >= '"+cFilialDe+"' AND CVX_FILIAL <= '"+cFilialAte+"'"
EndIf	
cQuery += " AND CVX_TPSALD = '"+cTpSaldo+"' "
cQuery += " AND CVX_DATA >= '"+DTOS(dDataIni)+"' AND CVX_DATA <= '"+DTOS(dDataFim)+"'"
If ! lAllMoedas
	cQuery += " AND CVX_MOEDA = '"+cQualMoed+"'"
EndIf
cQuery += " AND D_E_L_E_T_ = ' '"

If TcSqlExec(cQuery) <> 0
	UserException( "Erro na exclusใo dos saldos diarios "+ CRLF + "Processo cancelado..."+ CRLF + TCSqlError() )
	Return
EndIf


If ValType(oObj) == "O"
	oObj:IncRegua1(STR0009) //"Zerando arquivos de saldos mensal do cubo..."
EndIf

//Apagar todos os saldos mensais (CVY) entre data inicial e final
cQuery := ""
If __lFKInUse                 
	cQuery  += " UPDATE " + RetSqlName('CVY')
	cQuery  += " SET D_E_L_E_T_ = '*', R_E_C_D_E_L_ = R_E_C_N_O_ "
Else
	cQuery += " DELETE FROM " +RetSqlName("CVY")
EndIf
cQuery += " WHERE "
If !Empty(cFilialDe) .And. cFilialDe == cFilialAte
	cQuery += " CVY_FILIAL = '"+xFilial("CVY",cFilialDe)+"'"
Else
	cQuery += " CVY_FILIAL >= '"+cFilialDe+"' AND CVY_FILIAL <= '"+cFilialAte+"'"
EndIf	
cQuery += " AND CVY_TPSALD = '"+cTpSaldo+"' "
cQuery += " AND CVY_DATA >= '"+DTOS(LastDay(dDataIni))+"' AND CVY_DATA <= '"+DTOS(LastDay(dDataFim))+"'"
If ! lAllMoedas
	cQuery += " AND CVY_MOEDA = '"+cQualMoed+"'"
EndIf
cQuery += " AND D_E_L_E_T_ = ' '"

If TcSqlExec(cQuery) <> 0
	UserException( STR0006+ CRLF + STR0007+ CRLF + TCSqlError() )  //"Erro na exclusใo dos saldos mensais"##"Processo cancelado..."
	Return
EndIf

If ValType(oObj) == "O"
	oObj:IncRegua1(STR0010) //"Atualizando saldos do cubo..."
EndIf

//Refazer os saldos mensais entre data inicial e final somando todos os saldos diarios (CVX) entre o mes da data inicial e o mes da data final
//agrupando por mes e atualizando registros correspondentes nos saldos mensais (CVY)
cQuery := ""
cQuery += " SELECT CVX_FILIAL, CVX_CONFIG, CVX_MOEDA, CVX_TPSALD, SUBSTRING(CVX_DATA,1,6) MESANO, 
For nX := 1 TO 9
	If CVX->(FieldPos("CVX_NIV"+StrZero(nX,2))) > 0
		cQuery += "CVX_NIV"+StrZero(nX,2)+", "
	EndIf	
Next
cQuery += " SUM(CVX_SLDDEB) CVX_DEBITO, SUM(CVX_SLDCRD) CREDITO FROM " +RetSqlName("CVX")
cQuery += " WHERE "
If !Empty(cFilialDe) .And. cFilialDe == cFilialAte
	cQuery += " CVX_FILIAL = '"+xFilial("CVX",cFilialDe)+"'"
Else                                    
	cQuery += " CVX_FILIAL >= '"+cFilialDe+"' AND CVX_FILIAL <= '"+cFilialAte+"'"
EndIf	
cQuery += " AND CVX_TPSALD = '"+cTpSaldo+"' "
cQuery += " AND CVX_DATA >= '"+DTOS(dDataIni)+"' AND CVX_DATA <= '"+DTOS(dDataFim)+"'"
If ! lAllMoedas
	cQuery += " AND CVX_MOEDA = '"+cQualMoed+"'"
EndIf
cQuery += " AND D_E_L_E_T_ = ' '"

If Alltrim(Upper(TcGetDb())) == "INFORMIX" .OR. Alltrim(Upper(TcGetDb())) == "POSTGRES"
	cQuery += " GROUP BY 1, 2, 3, 4, 5, "
	For nX := 1 TO 9
		If CVX->(FieldPos("CVX_NIV"+StrZero(nX,2))) > 0
			cQuery += Str(nX+5,2,0)+", "
		EndIf	
	Next
Else
	cQuery += " GROUP BY CVX_FILIAL, CVX_CONFIG, CVX_MOEDA, CVX_TPSALD, SUBSTRING(CVX_DATA,1,6), "
	For nX := 1 TO 9
		If CVX->(FieldPos("CVX_NIV"+StrZero(nX,2))) > 0
			cQuery += "CVX_NIV"+StrZero(nX,2)+", "
		EndIf	
	Next
EndIf
cQuery := Substr(cQuery, 1, Len(cQuery)-2)
cQuery := ChangeQuery(cQuery)

dbUseArea( .T., "TopConn", TCGenQry(,,cQuery),"TMPREPROC", .F., .F. )

While TMPREPROC->( ! Eof() )
	
	dbSelectArea("CVY")
	RecLock("CVY", .T.)
	CVY->CVY_FILIAL := TMPREPROC->CVY_FILIAL
	CVY->CVY_CONFIG	 := TMPREPROC->CVY_CONFIG
	CVY->CVY_MOEDA := TMPREPROC->CVY_MOEDA
	CVY->CVY_TPSALD := TMPREPROC->CVY_TPSALD
	CVY->CVY_DATA := LastDay(STOD(TMPREPROC->MESANO+"01"))
	For nX := 1 TO 9
		If CVY->(FieldPos("CVY_NIV"+StrZero(nX,2))) > 0
			&("CVY->CVY_NIV"+StrZero(nX,2) ) := &("TMPREPROC->CVX_NIV"+StrZero(nX,2) )
		EndIf	
	Next
	MsUnlock()

	TMPREPROC->( dbSkip() )

EndDo

dbSelectArea("TMPREPROC")
dbCloseArea()

SM0->(MsSeek(cEmpAnt+cFilialDe,.T.))

//selecionar nos movimentos contabeis (CT2) para as condicoes recebidas pela funcao e fazer um loop chamando a funcao Ctb_Run_Cubes para cada registro)
While !SM0->(Eof()) .and. IIf( lFWCodFil, FWGETCODFILIAL, SM0->M0_CODFIL ) <= cFilialAte .and. SM0->M0_CODIGO == cEmpAnt
	cFilAnt := IIf( lFWCodFil, FWGETCODFILIAL, SM0->M0_CODFIL )

	cQuery := ""
	cQuery += " SELECT * FROM " +RetSqlName("CT2")
	cQuery += " WHERE CT2_FILIAL = '"+xFilial("CT2")+"'"
	cQuery += " AND CT2_TPSALD = '"+cTpSaldo+"' "
	cQuery += " AND CT2_DATA >= '"+DTOS(dDataIni)+"' AND CT2_DATA <= '"+DTOS(dDataFim)+"'"

	If ! lAllMoedas
		cQuery += " AND CT2_MOEDLC = '"+cQualMoed+"'"
	EndIf

	cQuery += " AND D_E_L_E_T_ = ' '"
	
	cQuery := ChangeQuery(cQuery)
	cAliasMov := GetNextAlias()
	
	dbUseArea( .T., "TopConn", TCGenQry(,,cQuery),cAliasMov, .F., .F. )
	TCSetField(cAliasMov,"CT2_DATA", "D",8,0)				  		
	TCSetField(cAliasMov,"CT2_VALOR", "N",17,4)	
	
	dbSelectArea(cAliasMov)
	While (cAliasMov)->(! Eof() )

		If (cAliasMov)->CT2_TPSALD != '9'
			Ctb_Run_Cubes(oConjCubos, cAliasMov, "+")
		EndIf	

		(cAliasMov)->( dbSkip() )
	EndDo
	
	If !lExclusivo //Se o arquivo e' compartilhado, so devera ser lido apenas uma vez!!
		Exit
	Endif
	
	dbSelectArea(cAliasMov)
	dbCloseArea()

	dbSelectArea("SM0")
	dbSkip()
Enddo

dbSelectArea("CT2")

Return
/* ----------------------------------------------------------------------------

_CTB_CUBE()

Fun็ใo dummy para permitir a gera็ใo de patch deste arquivo fonte.

---------------------------------------------------------------------------- */
Function _CTB_CUBE()
Return Nil	


/*
//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ                       classe colecao de cubos                       ณ
//ณ Classe para colecao de cubos utilizados para atualizacao dos saldos ณ
//ณ                                                                     ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
*/

// --------------------------------------------------------------------------------
// Declaracao da Classe Cubes_Set
// --------------------------------------------------------------------------------

CLASS CtbCubes_Set
// Declaracao das propriedades da Classe
DATA aCubes_Set
DATA nLinePosition
DATA nNumCubes

// Declara็ใo dos M้todos da Classe
METHOD New() CONSTRUCTOR
METHOD GetCube_Set()
METHOD SetAddCube_Set(oCube)
METHOD GetCube()
METHOD CountCube()
METHOD GetPosition()
METHOD SetPosition(nLinePosition)
ENDCLASS

// Cria็ใo do construtor, onde atribuimos os valores default 
// para as propriedades e retornamos Self
METHOD New() CLASS CtbCubes_Set
Self:aCubes_Set := {}
Self:nLinePosition := 0
Self:nNumCubes := 0
Return Self

METHOD GetCube_Set() CLASS CtbCubes_Set
Return Self:aCubes_Set

METHOD SetAddCube_Set(oCube) CLASS CtbCubes_Set
aAdd(Self:aCubes_Set, oCube)
Self:nNumCubes++
Return 

METHOD GetCube() CLASS CtbCubes_Set
Return Self:aCubes_Set[Self:nLinePosition]

METHOD CountCube() CLASS CtbCubes_Set
Return Self:nNumCubes

METHOD GetPosition() CLASS CtbCubes_Set
Return Self:nLinePosition

METHOD SetPosition(nLinePosition) CLASS CtbCubes_Set
Self:nLinePosition := nLinePosition
Return 
/* ----------------------------------------------------------------------------

_CTB_CUBSET()

Fun็ใo dummy para permitir a gera็ใo de patch deste arquivo fonte.

---------------------------------------------------------------------------- */
Function _CTB_CUBSET()
Return Nil	
