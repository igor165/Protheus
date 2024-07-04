#include "protheus.ch"
#include "pms.ch"

#define PMS_NULL 0

/* ----------------------------------------------------------------------------

PmsNode

A classe Node representa um elemento da árvore da estrutura do projeto,
armazenando informações para o funcionamento da mesma.
	
Ela serve de classe base para a classe Task, a qual armazena os detalhes
da tarefa.

---------------------------------------------------------------------------- */
Class PmsNode
	Data Id As Integer
	Data Dirty As Boolean

	Data ParentNode As PmsNode
	
	Method GetParentNode()
	Method SetParentNode()
	
	Data Children As PmsNode
	
	Method GetChildren()

	Data PreviousSibling As PmsNode
	Data NextSibling As PmsNode
	
	Data Text As String
	
	Method New() Constructor
	
	Method AppendChild()
	Method RemoveChild()
	
	Method GetLevel()
EndClass

/* ----------------------------------------------------------------------------

PmsNode:New()
  
Método construtor

---------------------------------------------------------------------------- */
Method New() Class PmsNode
	Self:Id    := PMS_NULL
	Self:Dirty := .F.
	
	Self:Text := ""

	Self:ParentNode := Nil
	
	Self:Children := Nil
	
	Self:PreviousSibling := Nil
	Self:NextSibling := Nil
Return Nil

/* ----------------------------------------------------------------------------

PmsNode:AppendChild()

---------------------------------------------------------------------------- */
Method AppendChild(Node) Class PmsNode
	Local AuxNode  := Self:Children
	Local Appended := .F.
	
	Node:ParentNode := Self	
	Node:NextSibling := Nil

	If AuxNode == Nil
		Node:PreviousSibling := Nil
		Self:Children := Node		
	Else
		While AuxNode:NextSibling # Nil
			AuxNode := AuxNode:NextSibling
		End

		Node:PreviousSibling := AuxNode
		AuxNode:NextSibling := Node
	EndIf
	
	Appended := .T.
Return Appended

/* ----------------------------------------------------------------------------

PmsNode:RemoveChild()

Metódo ainda não implementado

---------------------------------------------------------------------------- */
Method RemoveChild(Node) Class PmsNode
	Local AuxNode := Self:Children
	Local Removed := .F.

	If AuxNode == Nil
		Return Removed
	EndIf

	While AuxNode:NextSibling # Nil
		If AuxNode == Node

			// ...
							
		EndIf
		
		AuxNode := AuxNode:NextSibling
	End
	
	Removed := .T.
Return Removed

/* ----------------------------------------------------------------------------

PmsNode:GetLevel()

---------------------------------------------------------------------------- */
Method GetLevel() Class PmsNode
	Local Level := 0
	Local AuxNode := Nil
	
	AuxNode := Self

	While AuxNode # Nil
		Level++	
		AuxNode := AuxNode:ParentNode
	End

Return Level

/* ----------------------------------------------------------------------------

PmsNode:GetParentNode()

---------------------------------------------------------------------------- */
Method GetParentNode() Class PmsNode
Return Self:ParentNode

/* ----------------------------------------------------------------------------

PmsNode:SetParentNode()

---------------------------------------------------------------------------- */
Method SetParentNode(Value) Class PmsNode
	If Value == Nil
		Return .F.
	Else
		Self:ParentNode := Value
	EndIf
Return .T.

/* ----------------------------------------------------------------------------

PmsNode:GetChildren()

---------------------------------------------------------------------------- */
Method GetChildren() Class PmsNode
Return Self:Children

/* ----------------------------------------------------------------------------

_a349xkd()

Função dummy para permitir a geração de patch deste arquivo fonte.

---------------------------------------------------------------------------- */
Function _a349xkd()
Return Nil
