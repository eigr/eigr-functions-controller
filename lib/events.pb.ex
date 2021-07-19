defmodule Io.Eigr.Permastate.Operator.Resource.Kind do
  @moduledoc false
  use Protobuf, enum: true, syntax: :proto3
  @type t :: integer | :STATEFUL_SERVICE | :STATEFUL_STORE | :CONFIG_MAP | :SECRETS | :SERVICE

  def descriptor do
    # credo:disable-for-next-line
    Elixir.Google.Protobuf.EnumDescriptorProto.decode(
      <<10, 4, 75, 105, 110, 100, 18, 20, 10, 16, 83, 84, 65, 84, 69, 70, 85, 76, 95, 83, 69, 82,
        86, 73, 67, 69, 16, 0, 18, 18, 10, 14, 83, 84, 65, 84, 69, 70, 85, 76, 95, 83, 84, 79, 82,
        69, 16, 1, 18, 14, 10, 10, 67, 79, 78, 70, 73, 71, 95, 77, 65, 80, 16, 2, 18, 11, 10, 7,
        83, 69, 67, 82, 69, 84, 83, 16, 3, 18, 11, 10, 7, 83, 69, 82, 86, 73, 67, 69, 16, 4>>
    )
  end

  field :STATEFUL_SERVICE, 0

  field :STATEFUL_STORE, 1

  field :CONFIG_MAP, 2

  field :SECRETS, 3

  field :SERVICE, 4
end

defmodule Io.Eigr.Permastate.Operator.Session do
  @moduledoc false
  use Protobuf, syntax: :proto3

  @type t :: %__MODULE__{
          id: String.t()
        }

  defstruct [:id]

  def descriptor do
    # credo:disable-for-next-line
    Elixir.Google.Protobuf.DescriptorProto.decode(
      <<10, 7, 83, 101, 115, 115, 105, 111, 110, 18, 14, 10, 2, 105, 100, 24, 1, 32, 1, 40, 9, 82,
        2, 105, 100>>
    )
  end

  field :id, 1, type: :string
end

defmodule Io.Eigr.Permastate.Operator.Login do
  @moduledoc false
  use Protobuf, syntax: :proto3

  @type t :: %__MODULE__{
          session: Io.Eigr.Permastate.Operator.Session.t() | nil
        }

  defstruct [:session]

  def descriptor do
    # credo:disable-for-next-line
    Elixir.Google.Protobuf.DescriptorProto.decode(
      <<10, 5, 76, 111, 103, 105, 110, 18, 62, 10, 7, 115, 101, 115, 115, 105, 111, 110, 24, 1,
        32, 1, 40, 11, 50, 36, 46, 105, 111, 46, 101, 105, 103, 114, 46, 112, 101, 114, 109, 97,
        115, 116, 97, 116, 101, 46, 111, 112, 101, 114, 97, 116, 111, 114, 46, 83, 101, 115, 115,
        105, 111, 110, 82, 7, 115, 101, 115, 115, 105, 111, 110>>
    )
  end

  field :session, 1, type: Io.Eigr.Permastate.Operator.Session
end

defmodule Io.Eigr.Permastate.Operator.Logout do
  @moduledoc false
  use Protobuf, syntax: :proto3

  @type t :: %__MODULE__{
          session: Io.Eigr.Permastate.Operator.Session.t() | nil
        }

  defstruct [:session]

  def descriptor do
    # credo:disable-for-next-line
    Elixir.Google.Protobuf.DescriptorProto.decode(
      <<10, 6, 76, 111, 103, 111, 117, 116, 18, 62, 10, 7, 115, 101, 115, 115, 105, 111, 110, 24,
        1, 32, 1, 40, 11, 50, 36, 46, 105, 111, 46, 101, 105, 103, 114, 46, 112, 101, 114, 109,
        97, 115, 116, 97, 116, 101, 46, 111, 112, 101, 114, 97, 116, 111, 114, 46, 83, 101, 115,
        115, 105, 111, 110, 82, 7, 115, 101, 115, 115, 105, 111, 110>>
    )
  end

  field :session, 1, type: Io.Eigr.Permastate.Operator.Session
end

defmodule Io.Eigr.Permastate.Operator.Session do
  @moduledoc false
  use Protobuf, syntax: :proto3

  @type t :: %__MODULE__{
          id: String.t()
        }

  defstruct [:id]

  def descriptor do
    # credo:disable-for-next-line
    Elixir.Google.Protobuf.DescriptorProto.decode(
      <<10, 7, 83, 101, 115, 115, 105, 111, 110, 18, 14, 10, 2, 105, 100, 24, 1, 32, 1, 40, 9, 82,
        2, 105, 100>>
    )
  end

  field(:id, 1, type: :string)
end

defmodule Io.Eigr.Permastate.Operator.Login do
  @moduledoc false
  use Protobuf, syntax: :proto3

  @type t :: %__MODULE__{
          session: Io.Eigr.Permastate.Operator.Session.t() | nil
        }

  defstruct [:session]

  def descriptor do
    # credo:disable-for-next-line
    Elixir.Google.Protobuf.DescriptorProto.decode(
      <<10, 5, 76, 111, 103, 105, 110, 18, 62, 10, 7, 115, 101, 115, 115, 105, 111, 110, 24, 1,
        32, 1, 40, 11, 50, 36, 46, 105, 111, 46, 101, 105, 103, 114, 46, 112, 101, 114, 109, 97,
        115, 116, 97, 116, 101, 46, 111, 112, 101, 114, 97, 116, 111, 114, 46, 83, 101, 115, 115,
        105, 111, 110, 82, 7, 115, 101, 115, 115, 105, 111, 110>>
    )
  end

  field(:session, 1, type: Io.Eigr.Permastate.Operator.Session)
end

defmodule Io.Eigr.Permastate.Operator.Logout do
  @moduledoc false
  use Protobuf, syntax: :proto3

  @type t :: %__MODULE__{
          session: Io.Eigr.Permastate.Operator.Session.t() | nil
        }

  defstruct [:session]

  def descriptor do
    # credo:disable-for-next-line
    Elixir.Google.Protobuf.DescriptorProto.decode(
      <<10, 6, 76, 111, 103, 111, 117, 116, 18, 62, 10, 7, 115, 101, 115, 115, 105, 111, 110, 24,
        1, 32, 1, 40, 11, 50, 36, 46, 105, 111, 46, 101, 105, 103, 114, 46, 112, 101, 114, 109,
        97, 115, 116, 97, 116, 101, 46, 111, 112, 101, 114, 97, 116, 111, 114, 46, 83, 101, 115,
        115, 105, 111, 110, 82, 7, 115, 101, 115, 115, 105, 111, 110>>
    )
  end

  field(:session, 1, type: Io.Eigr.Permastate.Operator.Session)
end

defmodule Io.Eigr.Permastate.Operator.Resource.MetadataEntry do
  @moduledoc false
  use Protobuf, map: true, syntax: :proto3

  @type t :: %__MODULE__{
          key: String.t(),
          value: String.t()
        }

  defstruct [:key, :value]

  def descriptor do
    # credo:disable-for-next-line
    Elixir.Google.Protobuf.DescriptorProto.decode(
      <<10, 13, 77, 101, 116, 97, 100, 97, 116, 97, 69, 110, 116, 114, 121, 18, 16, 10, 3, 107,
        101, 121, 24, 1, 32, 1, 40, 9, 82, 3, 107, 101, 121, 18, 20, 10, 5, 118, 97, 108, 117,
        101, 24, 2, 32, 1, 40, 9, 82, 5, 118, 97, 108, 117, 101, 58, 8, 8, 0, 16, 0, 24, 0, 56,
        1>>
    )
  end

  field :key, 1, type: :string
  field :value, 2, type: :string
end

defmodule Io.Eigr.Permastate.Operator.Resource do
  @moduledoc false
  use Protobuf, syntax: :proto3

  @type t :: %__MODULE__{
          name: String.t(),
          metadata: %{String.t() => String.t()},
          kind: Io.Eigr.Permastate.Operator.Resource.Kind.t()
        }

  defstruct [:name, :metadata, :kind]

  def descriptor do
    # credo:disable-for-next-line
    Elixir.Google.Protobuf.DescriptorProto.decode(
      <<10, 8, 82, 101, 115, 111, 117, 114, 99, 101, 18, 18, 10, 4, 110, 97, 109, 101, 24, 1, 32,
        1, 40, 9, 82, 4, 110, 97, 109, 101, 18, 79, 10, 8, 109, 101, 116, 97, 100, 97, 116, 97,
        24, 2, 32, 3, 40, 11, 50, 51, 46, 105, 111, 46, 101, 105, 103, 114, 46, 112, 101, 114,
        109, 97, 115, 116, 97, 116, 101, 46, 111, 112, 101, 114, 97, 116, 111, 114, 46, 82, 101,
        115, 111, 117, 114, 99, 101, 46, 77, 101, 116, 97, 100, 97, 116, 97, 69, 110, 116, 114,
        121, 82, 8, 109, 101, 116, 97, 100, 97, 116, 97, 18, 62, 10, 4, 107, 105, 110, 100, 24, 3,
        32, 1, 40, 14, 50, 42, 46, 105, 111, 46, 101, 105, 103, 114, 46, 112, 101, 114, 109, 97,
        115, 116, 97, 116, 101, 46, 111, 112, 101, 114, 97, 116, 111, 114, 46, 82, 101, 115, 111,
        117, 114, 99, 101, 46, 75, 105, 110, 100, 82, 4, 107, 105, 110, 100, 26, 65, 10, 13, 77,
        101, 116, 97, 100, 97, 116, 97, 69, 110, 116, 114, 121, 18, 16, 10, 3, 107, 101, 121, 24,
        1, 32, 1, 40, 9, 82, 3, 107, 101, 121, 18, 20, 10, 5, 118, 97, 108, 117, 101, 24, 2, 32,
        1, 40, 9, 82, 5, 118, 97, 108, 117, 101, 58, 8, 8, 0, 16, 0, 24, 0, 56, 1, 34, 90, 10, 4,
        75, 105, 110, 100, 18, 20, 10, 16, 83, 84, 65, 84, 69, 70, 85, 76, 95, 83, 69, 82, 86, 73,
        67, 69, 16, 0, 18, 18, 10, 14, 83, 84, 65, 84, 69, 70, 85, 76, 95, 83, 84, 79, 82, 69, 16,
        1, 18, 14, 10, 10, 67, 79, 78, 70, 73, 71, 95, 77, 65, 80, 16, 2, 18, 11, 10, 7, 83, 69,
        67, 82, 69, 84, 83, 16, 3, 18, 11, 10, 7, 83, 69, 82, 86, 73, 67, 69, 16, 4>>
    )
  end

  field :name, 1, type: :string

  field :metadata, 2,
    repeated: true,
    type: Io.Eigr.Permastate.Operator.Resource.MetadataEntry,
    map: true

  field :kind, 3, type: Io.Eigr.Permastate.Operator.Resource.Kind, enum: true
end

defmodule Io.Eigr.Permastate.Operator.Scale do
  @moduledoc false
  use Protobuf, syntax: :proto3

  @type t :: %__MODULE__{
          replicas: integer,
          resource: Io.Eigr.Permastate.Operator.Resource.t() | nil
        }

  defstruct [:replicas, :resource]

  def descriptor do
    # credo:disable-for-next-line
    Elixir.Google.Protobuf.DescriptorProto.decode(
      <<10, 5, 83, 99, 97, 108, 101, 18, 26, 10, 8, 114, 101, 112, 108, 105, 99, 97, 115, 24, 1,
        32, 1, 40, 5, 82, 8, 114, 101, 112, 108, 105, 99, 97, 115, 18, 65, 10, 8, 114, 101, 115,
        111, 117, 114, 99, 101, 24, 2, 32, 1, 40, 11, 50, 37, 46, 105, 111, 46, 101, 105, 103,
        114, 46, 112, 101, 114, 109, 97, 115, 116, 97, 116, 101, 46, 111, 112, 101, 114, 97, 116,
        111, 114, 46, 82, 101, 115, 111, 117, 114, 99, 101, 82, 8, 114, 101, 115, 111, 117, 114,
        99, 101>>
    )
  end

  field :replicas, 1, type: :int32
  field :resource, 2, type: Io.Eigr.Permastate.Operator.Resource
end

defmodule Io.Eigr.Permastate.Operator.Create do
  @moduledoc false
  use Protobuf, syntax: :proto3

  @type t :: %__MODULE__{
          resource: Io.Eigr.Permastate.Operator.Resource.t() | nil
        }

  defstruct [:resource]

  def descriptor do
    # credo:disable-for-next-line
    Elixir.Google.Protobuf.DescriptorProto.decode(
      <<10, 6, 67, 114, 101, 97, 116, 101, 18, 65, 10, 8, 114, 101, 115, 111, 117, 114, 99, 101,
        24, 1, 32, 1, 40, 11, 50, 37, 46, 105, 111, 46, 101, 105, 103, 114, 46, 112, 101, 114,
        109, 97, 115, 116, 97, 116, 101, 46, 111, 112, 101, 114, 97, 116, 111, 114, 46, 82, 101,
        115, 111, 117, 114, 99, 101, 82, 8, 114, 101, 115, 111, 117, 114, 99, 101>>
    )
  end

  field :resource, 1, type: Io.Eigr.Permastate.Operator.Resource
end

defmodule Io.Eigr.Permastate.Operator.Delete do
  @moduledoc false
  use Protobuf, syntax: :proto3

  @type t :: %__MODULE__{
          resource: Io.Eigr.Permastate.Operator.Resource.t() | nil
        }

  defstruct [:resource]

  def descriptor do
    # credo:disable-for-next-line
    Elixir.Google.Protobuf.DescriptorProto.decode(
      <<10, 6, 68, 101, 108, 101, 116, 101, 18, 65, 10, 8, 114, 101, 115, 111, 117, 114, 99, 101,
        24, 1, 32, 1, 40, 11, 50, 37, 46, 105, 111, 46, 101, 105, 103, 114, 46, 112, 101, 114,
        109, 97, 115, 116, 97, 116, 101, 46, 111, 112, 101, 114, 97, 116, 111, 114, 46, 82, 101,
        115, 111, 117, 114, 99, 101, 82, 8, 114, 101, 115, 111, 117, 114, 99, 101>>
    )
  end

  field :resource, 1, type: Io.Eigr.Permastate.Operator.Resource
end

defmodule Io.Eigr.Permastate.Operator.Modify do
  @moduledoc false
  use Protobuf, syntax: :proto3

  @type t :: %__MODULE__{
          resource: Io.Eigr.Permastate.Operator.Resource.t() | nil
        }

  defstruct [:resource]

  def descriptor do
    # credo:disable-for-next-line
    Elixir.Google.Protobuf.DescriptorProto.decode(
      <<10, 6, 77, 111, 100, 105, 102, 121, 18, 65, 10, 8, 114, 101, 115, 111, 117, 114, 99, 101,
        24, 1, 32, 1, 40, 11, 50, 37, 46, 105, 111, 46, 101, 105, 103, 114, 46, 112, 101, 114,
        109, 97, 115, 116, 97, 116, 101, 46, 111, 112, 101, 114, 97, 116, 111, 114, 46, 82, 101,
        115, 111, 117, 114, 99, 101, 82, 8, 114, 101, 115, 111, 117, 114, 99, 101>>
    )
  end

  field :resource, 1, type: Io.Eigr.Permastate.Operator.Resource
end

defmodule Io.Eigr.Permastate.Operator.Apply do
  @moduledoc false
  use Protobuf, syntax: :proto3

  @type t :: %__MODULE__{
          action: {atom, any},
          session: Io.Eigr.Permastate.Operator.Session.t() | nil
        }

  defstruct [:action, :session]

  def descriptor do
    # credo:disable-for-next-line
    Elixir.Google.Protobuf.DescriptorProto.decode(
      <<10, 5, 65, 112, 112, 108, 121, 18, 58, 10, 5, 115, 99, 97, 108, 101, 24, 1, 32, 1, 40, 11,
        50, 34, 46, 105, 111, 46, 101, 105, 103, 114, 46, 112, 101, 114, 109, 97, 115, 116, 97,
        116, 101, 46, 111, 112, 101, 114, 97, 116, 111, 114, 46, 83, 99, 97, 108, 101, 72, 0, 82,
        5, 115, 99, 97, 108, 101, 18, 61, 10, 6, 100, 101, 108, 101, 116, 101, 24, 2, 32, 1, 40,
        11, 50, 35, 46, 105, 111, 46, 101, 105, 103, 114, 46, 112, 101, 114, 109, 97, 115, 116,
        97, 116, 101, 46, 111, 112, 101, 114, 97, 116, 111, 114, 46, 68, 101, 108, 101, 116, 101,
        72, 0, 82, 6, 100, 101, 108, 101, 116, 101, 18, 62, 10, 7, 115, 101, 115, 115, 105, 111,
        110, 24, 3, 32, 1, 40, 11, 50, 36, 46, 105, 111, 46, 101, 105, 103, 114, 46, 112, 101,
        114, 109, 97, 115, 116, 97, 116, 101, 46, 111, 112, 101, 114, 97, 116, 111, 114, 46, 83,
        101, 115, 115, 105, 111, 110, 82, 7, 115, 101, 115, 115, 105, 111, 110, 66, 8, 10, 6, 97,
        99, 116, 105, 111, 110>>
    )
  end

  oneof :action, 0
  field :scale, 1, type: Io.Eigr.Permastate.Operator.Scale, oneof: 0
  field :delete, 2, type: Io.Eigr.Permastate.Operator.Delete, oneof: 0
  field :session, 3, type: Io.Eigr.Permastate.Operator.Session
end

defmodule Io.Eigr.Permastate.Operator.Event do
  @moduledoc false
  use Protobuf, syntax: :proto3

  @type t :: %__MODULE__{
          data: {atom, any}
        }

  defstruct [:data]

  def descriptor do
    # credo:disable-for-next-line
    Elixir.Google.Protobuf.DescriptorProto.decode(
      <<10, 5, 69, 118, 101, 110, 116, 18, 61, 10, 6, 99, 114, 101, 97, 116, 101, 24, 1, 32, 1,
        40, 11, 50, 35, 46, 105, 111, 46, 101, 105, 103, 114, 46, 112, 101, 114, 109, 97, 115,
        116, 97, 116, 101, 46, 111, 112, 101, 114, 97, 116, 111, 114, 46, 67, 114, 101, 97, 116,
        101, 72, 0, 82, 6, 99, 114, 101, 97, 116, 101, 18, 61, 10, 6, 100, 101, 108, 101, 116,
        101, 24, 2, 32, 1, 40, 11, 50, 35, 46, 105, 111, 46, 101, 105, 103, 114, 46, 112, 101,
        114, 109, 97, 115, 116, 97, 116, 101, 46, 111, 112, 101, 114, 97, 116, 111, 114, 46, 68,
        101, 108, 101, 116, 101, 72, 0, 82, 6, 100, 101, 108, 101, 116, 101, 18, 61, 10, 6, 109,
        111, 100, 105, 102, 121, 24, 3, 32, 1, 40, 11, 50, 35, 46, 105, 111, 46, 101, 105, 103,
        114, 46, 112, 101, 114, 109, 97, 115, 116, 97, 116, 101, 46, 111, 112, 101, 114, 97, 116,
        111, 114, 46, 77, 111, 100, 105, 102, 121, 72, 0, 82, 6, 109, 111, 100, 105, 102, 121, 18,
        60, 10, 6, 108, 111, 103, 105, 110, 103, 24, 4, 32, 1, 40, 11, 50, 34, 46, 105, 111, 46,
        101, 105, 103, 114, 46, 112, 101, 114, 109, 97, 115, 116, 97, 116, 101, 46, 111, 112, 101,
        114, 97, 116, 111, 114, 46, 76, 111, 103, 105, 110, 72, 0, 82, 6, 108, 111, 103, 105, 110,
        103, 18, 61, 10, 6, 108, 111, 103, 111, 117, 116, 24, 5, 32, 1, 40, 11, 50, 35, 46, 105,
        111, 46, 101, 105, 103, 114, 46, 112, 101, 114, 109, 97, 115, 116, 97, 116, 101, 46, 111,
        112, 101, 114, 97, 116, 111, 114, 46, 76, 111, 103, 111, 117, 116, 72, 0, 82, 6, 108, 111,
        103, 111, 117, 116, 18, 58, 10, 5, 97, 112, 112, 108, 121, 24, 6, 32, 1, 40, 11, 50, 34,
        46, 105, 111, 46, 101, 105, 103, 114, 46, 112, 101, 114, 109, 97, 115, 116, 97, 116, 101,
        46, 111, 112, 101, 114, 97, 116, 111, 114, 46, 65, 112, 112, 108, 121, 72, 0, 82, 5, 97,
        112, 112, 108, 121, 66, 6, 10, 4, 100, 97, 116, 97>>
    )
  end

  oneof :data, 0
  field :create, 1, type: Io.Eigr.Permastate.Operator.Create, oneof: 0
  field :delete, 2, type: Io.Eigr.Permastate.Operator.Delete, oneof: 0
  field :modify, 3, type: Io.Eigr.Permastate.Operator.Modify, oneof: 0
  field :loging, 4, type: Io.Eigr.Permastate.Operator.Login, oneof: 0
  field :logout, 5, type: Io.Eigr.Permastate.Operator.Logout, oneof: 0
  field :apply, 6, type: Io.Eigr.Permastate.Operator.Apply, oneof: 0
end

defmodule Io.Eigr.Permastate.Operator.OperatorService.Service do
  @moduledoc false
  use GRPC.Service, name: "io.eigr.permastate.operator.OperatorService"

  def descriptor do
    # credo:disable-for-next-line
    Elixir.Google.Protobuf.ServiceDescriptorProto.decode(
      <<10, 15, 79, 112, 101, 114, 97, 116, 111, 114, 83, 101, 114, 118, 105, 99, 101, 18, 95, 10,
        12, 72, 97, 110, 100, 108, 101, 69, 118, 101, 110, 116, 115, 18, 34, 46, 105, 111, 46,
        101, 105, 103, 114, 46, 112, 101, 114, 109, 97, 115, 116, 97, 116, 101, 46, 111, 112, 101,
        114, 97, 116, 111, 114, 46, 69, 118, 101, 110, 116, 26, 34, 46, 105, 111, 46, 101, 105,
        103, 114, 46, 112, 101, 114, 109, 97, 115, 116, 97, 116, 101, 46, 111, 112, 101, 114, 97,
        116, 111, 114, 46, 69, 118, 101, 110, 116, 34, 3, 136, 2, 0, 40, 1, 48, 1>>
    )
  end

  rpc :HandleEvents,
      stream(Io.Eigr.Permastate.Operator.Event),
      stream(Io.Eigr.Permastate.Operator.Event)
end

defmodule Io.Eigr.Permastate.Operator.OperatorService.Stub do
  @moduledoc false
  use GRPC.Stub, service: Io.Eigr.Permastate.Operator.OperatorService.Service
end
