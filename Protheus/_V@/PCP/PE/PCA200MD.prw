#include "protheus.ch"
User Function PCA200MD()
    Local cOpcx     := ParamixB[1] //Model ou View
    Local oStrMaster:= ParamixB[2] //Struct Header
    //Local oStrCmp   := ParamixB[3] //Struct Componente
    //Local oStrDet   := ParamixB[4] //Struct Detalhe
    Local cOrdem    := Iif(cOpcx == "VIEW",ParamixB[5],"0") //Ordem, somente enviado para view
 
    If cOpcx == "MODEL"   
        oStrMaster:AddField("Energia"               ,;   // [01]  C   Titulo do campo 
                            "Energia"               ,;   // [02]  C   ToolTip do campo
                            "G1_ENERG"              ,;   // [03]  C   Id do Field
                            "N"                     ,;   // [04]  C   Tipo do campo
                            11                      ,;   // [05]  N   Tamanho do campo
                            4                       ,;   // [06]  N   Decimal do campo
                            NIL                     ,;   // [07]  B   Code-block de valida��o do campo
                            NIL                     ,;   // [08]  B   Code-block de valida��o When do campo
                            NIL                     ,;   // [09]  A   Lista de valores permitido do campo
                            .F.                     ,;   // [10]  L   Indica se o campo tem preenchimento obrigat�rio
                            NIL                     ,;   // [11]  B   Code-block de inicializacao do campo
                            NIL                     ,;   // [12]  L   Indica se trata-se de um campo chave
                            NIL                     ,;   // [13]  L   Indica se o campo pode receber valor em uma opera��o de update.
                            .F.)                         // [14]  L   Indica se o campo � virtual
    ElseIf cOpcx == "VIEW"
        cOrdem := Soma1(cOrdem)
        oStrMaster:AddField("G1_ENERG"              ,;  // [01]  C   Nome do Campo
                            cOrdem                  ,;  // [02]  C   Ordem
                            "Energia"               ,;  // [03]  C   Titulo do campo   
                            "Energia"               ,;  // [04]  C   Descricao do campo
                            NIL                     ,;  // [05]  A   Array com Help
                            "N"                     ,;  // [06]  C   Tipo do campo
                            "@E 999,999.9999"       ,;  // [07]  C   Picture
                            NIL                     ,;  // [08]  B   Bloco de Picture Var
                            NIL                     ,;  // [09]  C   Consulta F3
                            .T.                     ,;  // [10]  L   Indica se o campo � alteravel
                            NIL                     ,;  // [11]  C   Pasta do campo
                            NIL                     ,;  // [12]  C   Agrupamento do campo
                            NIL                     ,;  // [13]  A   Lista de valores permitido do campo (Combo)
                            NIL                     ,;  // [14]  N   Tamanho maximo da maior op��o do combo
                            NIL                     ,;  // [15]  C   Inicializador de Browse]
                            .F.                     ,;  // [16]  L   Indica se o campo � virtual
                            NIL                     ,;  // [17]  C   Picture Variavel
                            NIL)                        // [18]  L   Indica pulo de linha ap�s o campo
    EndIf
 
Return Nil
