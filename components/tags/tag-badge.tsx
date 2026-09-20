export function TagBadge({ tag }: { tag: { name: string; color: string } }) {
  return (
    <span
      className="inline-flex items-center rounded-full border px-2 py-0.5 text-xs font-medium"
      style={{ backgroundColor: `${tag.color}1a`, borderColor: `${tag.color}66`, color: tag.color }}
    >
      {tag.name}
    </span>
  )
}
